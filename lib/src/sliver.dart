import 'dart:collection';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:recycler_list/recycler_list.dart';

import 'recycler.dart';
import 'scroll_delegate.dart';
import 'sliver_list.dart';

typedef ItemType = Object? Function(int index);

/// An element that lazily builds children for a [SliverMultiBoxAdaptorWidget].
///
/// Implements [RenderSliverBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverMultiBoxAdaptor].
class RecyclerSliverMultiBoxAdaptorElement extends SliverMultiBoxAdaptorElement {
  /// Creates an element that lazily builds children for the given widget.
  ///
  /// If `replaceMovedChildren` is set to true, a new child is proactively
  /// inflate for the index that was previously occupied by a child that moved
  /// to a new index. The layout offset of the moved child is copied over to the
  /// new child. RenderObjects, that depend on the layout offset of existing
  /// children during [RenderObject.performLayout] should set this to true
  /// (example: [RenderSliverList]). For RenderObjects that figure out the
  /// layout offset of their children without looking at the layout offset of
  /// existing children this should be set to false (example:
  /// [RenderSliverFixedExtentList]) to avoid inflating unnecessary children.
  RecyclerSliverMultiBoxAdaptorElement(super.widget, {bool replaceMovedChildren = false})
      : _replaceMovedChildren = replaceMovedChildren;

  final bool _replaceMovedChildren;

  final Recycler<Element> _recycler = Recycler<Element>();

  ItemTyper get itemTyper => (widget as SliverMultiBoxAdaptorWidget).delegate as ItemTyper;

  @override
  RecyclerRenderSliverList get renderObject => super.renderObject as RecyclerRenderSliverList;

  final SplayTreeMap<int, Element?> _childElements = SplayTreeMap<int, Element?>();
  RenderBox? _currentBeforeChild;

  @override
  void performRebuild() {
    super.performRebuild();
    _currentBeforeChild = null;
    bool childrenUpdated = false;
    assert(_currentlyUpdatingChildIndex == null);
    try {
      final SplayTreeMap<int, Element?> newChildren = SplayTreeMap<int, Element?>();
      final Map<int, double> indexToLayoutOffset = HashMap<int, double>();
      final SliverMultiBoxAdaptorWidget adaptorWidget = widget as SliverMultiBoxAdaptorWidget;
      void processElement(int index) {
        _currentlyUpdatingChildIndex = index;
        if (_childElements[index] != null && _childElements[index] != newChildren[index]) {
          // This index has an old child that isn't used anywhere and should be deactivated.
          _childElements[index] = updateChild(_childElements[index], null, index);
          childrenUpdated = true;
        }
        final Element? newChild = updateChild(newChildren[index], _build(index, adaptorWidget), index);
        if (newChild != null) {
          childrenUpdated = childrenUpdated || _childElements[index] != newChild;
          _childElements[index] = newChild;
          final SliverMultiBoxAdaptorParentData parentData = newChild.renderObject!.parentData! as SliverMultiBoxAdaptorParentData;
          if (index == 0) {
            parentData.layoutOffset = 0.0;
          } else if (indexToLayoutOffset.containsKey(index)) {
            parentData.layoutOffset = indexToLayoutOffset[index];
          }
          if (!parentData.keptAlive) {
            _currentBeforeChild = newChild.renderObject as RenderBox?;
          }
        } else {
          childrenUpdated = true;
          _childElements.remove(index);
        }
      }
      for (final int index in _childElements.keys.toList()) {
        final Key? key = _childElements[index]!.widget.key;
        final int? newIndex = key == null ? null : adaptorWidget.delegate.findIndexByKey(key);
        final SliverMultiBoxAdaptorParentData? childParentData =
        _childElements[index]!.renderObject?.parentData as SliverMultiBoxAdaptorParentData?;

        if (childParentData != null && childParentData.layoutOffset != null) {
          indexToLayoutOffset[index] = childParentData.layoutOffset!;
        }

        if (newIndex != null && newIndex != index) {
          // The layout offset of the child being moved is no longer accurate.
          if (childParentData != null) {
            childParentData.layoutOffset = null;
          }

          newChildren[newIndex] = _childElements[index];
          if (_replaceMovedChildren) {
            // We need to make sure the original index gets processed.
            newChildren.putIfAbsent(index, () => null);
          }
          // We do not want the remapped child to get deactivated during processElement.
          _childElements.remove(index);
        } else {
          newChildren.putIfAbsent(index, () => _childElements[index]);
        }
      }

      renderObject.debugChildIntegrityEnabled = false; // Moving children will temporary violate the integrity.
      newChildren.keys.forEach(processElement);
      // An element rebuild only updates existing children. The underflow check
      // is here to make sure we look ahead one more child if we were at the end
      // of the child list before the update. By doing so, we can update the max
      // scroll offset during the layout phase. Otherwise, the layout phase may
      // be skipped, and the scroll view may be stuck at the previous max
      // scroll offset.
      //
      // This logic is not needed if any existing children has been updated,
      // because we will not skip the layout phase if that happens.
      if (!childrenUpdated && _didUnderflow) {
        final int lastKey = _childElements.lastKey() ?? -1;
        final int rightBoundary = lastKey + 1;
        newChildren[rightBoundary] = _childElements[rightBoundary];
        processElement(rightBoundary);
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
      renderObject.debugChildIntegrityEnabled = true;
    }
  }

  Widget? _build(int index, SliverMultiBoxAdaptorWidget widget) {
    return widget.delegate.build(this, index);
  }

  @override
  void createChild(int index, { required RenderBox? after }) {
    assert(_currentlyUpdatingChildIndex == null);
    owner!.buildScope(this, () {
      final bool insertFirst = after == null;
      assert(insertFirst || _childElements[index-1] != null);
      _currentBeforeChild = insertFirst ? null : (_childElements[index-1]!.renderObject as RenderBox?);
      Element? newChild;
      try {
        final SliverMultiBoxAdaptorWidget adaptorWidget = widget as SliverMultiBoxAdaptorWidget;
        _currentlyUpdatingChildIndex = index;
        final obtainedChild = _obtainChild(index, adaptorWidget);
        newChild = updateChild(obtainedChild, _build(index, adaptorWidget), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
      }
    });
  }


  @override
  void forgetChild(Element child) {
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
    // _recycleChild(child, child.slot as int);
    super.forgetChild(child);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner!.buildScope(this, () {
      Element? testElemen; // TODO delete
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final element = _childElements[index];
        testElemen = element; // TODO delete
        if (itemTyper.itemType == null || !_recycleChild(element, index)) {
          final Element? result = updateChild(_childElements[index], null, index);
          assert(result == null);
        }
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
      // TODO delete
      // TODO delete
      // TODO delete
      if (child.parent != null) {
        debugger(message: 'sevenn debug 222');
        _recycleChild(testElemen!, index);
      }
      assert(child.parent == null);
    });
  }

  /// [New Feature] Obtain child element.
  Element? _obtainChild(int index, SliverMultiBoxAdaptorWidget widget) {
    Element? child = _childElements[index];
    if (child == null && itemTyper.itemType != null) {
      if (index < 0 || index >= childCount) {
        _onNotObtainChild(child, index);
        return null;
      }
      final type = itemTyper.itemType!.call(index);
      if (type == null) {
        _onNotObtainChild(child, index);
        return child;
      }
      child = _recycler.obtain(type);
      _onObtainChild(child, index);
      final childRenderObject = child?.renderObject;
      if (child != null && childRenderObject is RenderBox) {
        renderObject.obtainChild(childRenderObject, index);
      }
    }
    return child;
  }

  /// [New Feature] Recycle child element.
  bool _recycleChild(Element? child, int index) {
    if (child == null) {
      return false;
    }
    assert(child.slot != null);
    assert(itemTyper.itemType != null);
    final type = itemTyper.itemType!.call(index);
    if (type == null) {
      return false;
    }
    final childRenderObject = child.renderObject;
    if (childRenderObject is RenderBox) {
      final parentData = childRenderObject.parentData as SliverMultiBoxAdaptorParentData;
      parentData.layoutOffset = null;
      renderObject.recycleChild(childRenderObject);
    }
    _recycler.recycle(type, child);
    _onRecycleChild(child, index);
    return true;
  }

  /// [New Feature] Deactivate recycled child element.
  void _deactivateRecycledChildren() {
    assert(_currentlyUpdatingRecycledChild == false);
    try {
      _currentlyUpdatingRecycledChild = true;
      for (var typeList in _recycler.caches.values) {
        for (var e in typeList) {
          final childRenderObject = e.renderObject;
          if (childRenderObject is RenderBox) {
            renderObject.setupParentData(childRenderObject);
          }
          deactivateChild(e);
        }
      }
    } finally {
      _recycler.clear();
      _currentlyUpdatingRecycledChild = false;
    }
  }

  void _onNotObtainChild(Element? child, int index) {
    if (debugRecyclerList) {
      Logger.d('RecyclerList ----------- fail obtain $index');
    }
  }

  void _onObtainChild(Element? child, int index) {
    if (debugRecyclerList) {
      if (child == null) {
        Logger.d('RecyclerList ----------- create $index');
      } else {
        Logger.d('RecyclerList >>>>>>>>>>> obtain $index');
      }
    }
  }

  void _onRecycleChild(Element? child, int index) {
    if (debugRecyclerList) {
      Logger.d('RecyclerList <<<<<<<<<<< recycle $index');
    }
  }

  @override
  void deactivate() {
    _deactivateRecycledChildren();
    super.deactivate();
  }

  static double _extrapolateMaxScrollOffset(
      int firstIndex,
      int lastIndex,
      double leadingScrollOffset,
      double trailingScrollOffset,
      int childCount,
      ) {
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }
    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent = (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
      SliverConstraints? constraints, {
        int? firstIndex,
        int? lastIndex,
        double? leadingScrollOffset,
        double? trailingScrollOffset,
      }) {
    final int? childCount = estimatedChildCount;
    if (childCount == null) {
      return double.infinity;
    }
    return (widget as SliverMultiBoxAdaptorWidget).estimateMaxScrollOffset(
      constraints,
      firstIndex!,
      lastIndex!,
      leadingScrollOffset!,
      trailingScrollOffset!,
    ) ?? _extrapolateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
      childCount,
    );
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    final int firstIndex = _childElements.firstKey() ?? 0;
    final int lastIndex = _childElements.lastKey() ?? 0;
    (widget as SliverMultiBoxAdaptorWidget).delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int? _currentlyUpdatingChildIndex;

  bool _currentlyUpdatingRecycledChild = false;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, int slot) {
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child as RenderBox, after: _currentBeforeChild);
    assert(() {
      final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child, int oldSlot, int newSlot) {
    assert(_currentlyUpdatingChildIndex == newSlot);
    renderObject.move(child as RenderBox, after: _currentBeforeChild);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, int slot) {
    if (_currentlyUpdatingRecycledChild) {
      return;
    }
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(child as RenderBox);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    assert(!_childElements.values.any((Element? child) => child == null));
    _childElements.values.cast<Element>().toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.cast<Element>().where((Element child) {
      final SliverMultiBoxAdaptorParentData parentData = child.renderObject!.parentData! as SliverMultiBoxAdaptorParentData;
      final double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject!.paintBounds.width;
        case Axis.vertical:
          itemExtent = child.renderObject!.paintBounds.height;
      }

      return parentData.layoutOffset != null &&
          parentData.layoutOffset! < renderObject.constraints.scrollOffset + renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset! + itemExtent > renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}
