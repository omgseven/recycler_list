import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:recycler_list/recycler_list.dart';

import 'recycler.dart';
import 'scroll_delegate.dart';
import 'sliver_list.dart';

typedef ItemType = Object? Function(int index);

class RecyclerSliverMultiBoxAdaptorElement extends SliverMultiBoxAdaptorElement {
  RecyclerSliverMultiBoxAdaptorElement(super.widget, {super.replaceMovedChildren});

  final Recycler<Element> _recycler = Recycler<Element>();

  ItemTyper get itemTyper => (widget as SliverMultiBoxAdaptorWidget).delegate as ItemTyper;

  int _creatingChild = -1;
  int _removingChild = -1;
  bool _currentlyUpdatingRecycledChild = false;

  @override
  RecyclerRenderSliverList get renderObject => super.renderObject as RecyclerRenderSliverList;

  @override
  void createChild(int index, { required RenderBox? after }) {
    _creatingChild = _checkCreatingChildIndex(index, after: after);
    super.createChild(index, after: after);
    _creatingChild = -1;
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    _removingChild = index;
    super.removeChild(child);
    _removingChild = -1;
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    Element? newChild = child;
    if (_creatingChild >= 0) {
      // obtain recycled child
      final SliverMultiBoxAdaptorWidget adaptorWidget = widget as SliverMultiBoxAdaptorWidget;
      newChild = _obtainChild(child, _creatingChild, adaptorWidget);
    } else if (_removingChild >= 0) {
      assert(child != null);
      if (child != null && itemTyper.itemType != null && _recycleChild(child, _removingChild)) {
        // no deactivateChild
        return null;
      }
    }
    return super.updateChild(newChild, newWidget, newSlot);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, int slot) {
    if (_currentlyUpdatingRecycledChild) {
      return;
    }
    super.removeRenderObjectChild(child, slot);
  }

  @override
  void deactivate() {
    _deactivateRecycledChildren();
    super.deactivate();
  }

  /// [New Feature] Check creating child index.
  /// Avoid creating child when after already has a `next` item.
  /// In some cases like [1, 2] children is keep alive, and [3] is not, while
  /// rebuild listView after scroll [1, 2] out of screen, [3] will be created.
  ///
  /// see [RenderSliverList.performLayout.insertAndLayoutChild]
  int _checkCreatingChildIndex(int index, {RenderBox? after}) {
    if (after == null) {
      return index;
    }
    final childAtIndex = renderObject.childAfter(after);
    return childAtIndex == null ? index : -1;
  }

  /// [New Feature] Obtain child element.
  Element? _obtainChild(Element? child, int index, SliverMultiBoxAdaptorWidget widget) {
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

}
