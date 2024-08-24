import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

/// A mixin that provides item reusing for [RenderSliverMultiBoxAdaptor].
mixin RecyclerRenderSliverMultiBoxAdaptorMixin on RenderSliverMultiBoxAdaptor {

  void obtainChild(RenderBox child, int index) {
    setupParentData(child);
    final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
    childParentData.index = index;
    var after = _findChildBefore(index);
    insert(child, after: after);
  }

  void recycleChild(RenderBox child) {
    remove(child);
  }

  /// Used when listView rebuild.
  /// Sliver create every item from beginning to layout and sum up the height
  /// until current scroll offset, we should find out the item before index.
  RenderBox? _findChildBefore(int index) {
    RenderBox? child = lastChild;
    while (child != null) {
      final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
      if (childParentData.index! <= index) {
        return child;
      }
      child = childParentData.previousSibling;
    }
    return null;
  }
}

typedef OnVisibilityChanged = void Function(int index, ItemVisibilityInfo info);

/// A mixin that provides visibility change callback for [RenderSliverMultiBoxAdaptor].
mixin VisibilityChangeMixin on RenderSliverMultiBoxAdaptor {

  OnVisibilityChanged? childVisibilityChanged;

  @override
  void performLayout() {
    super.performLayout();
    if (childVisibilityChanged != null) {
      callbackVisibilityInfo(childVisibilityChanged!);
    }
  }

  void callbackVisibilityInfo(OnVisibilityChanged childVisibilityChanged) {
    var child = firstChild;
    while (child != null) {
      var index = indexOf(child);
      var mainAxisPosition = childMainAxisPosition(child);
      var visibilityInfo = ItemVisibilityInfo(
        constraints: constraints,
        size: child.size,
        offset: mainAxisPosition,
      );
      childVisibilityChanged(index, visibilityInfo);

      assert(child != childAfter(child));
      child = childAfter(child);
    }
  }
}


/// Data passed to the [onVisibilityChanged] callback.
class ItemVisibilityInfo {
  /// Constructor.
  ///
  /// 'viewPortSize' is the size of the viewport.
  /// 'size' is the size of the widget.
  /// 'offset' is the offset of the widget in the viewport visible area.
  const ItemVisibilityInfo({
    required this.constraints,
    required this.size,
    required this.offset,
  });

  /// The sliver constraints of the RenderSliver.
  final SliverConstraints constraints;

  /// The size of the widget.
  final Size size;

  /// The offset of the widget in the viewport visible area on the main axis.
  ///
  /// The offset is relative to the top-left corner of the viewport.
  final double offset;

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  double get visibleFraction {
    final visibleRange = this.visibleRange;
    var visibleFraction = (visibleRange.end - visibleRange.start)
        / constraints.viewportMainAxisExtent;

    if (nearEqual(visibleFraction, 0, _kDefaultTolerance)) {
      visibleFraction = 0;
    } else if (nearEqual(visibleFraction, 1, _kDefaultTolerance)) {
      // The inexact nature of floating-point arithmetic means that sometimes
      // the visible area might never equal the maximum area (or could even
      // be slightly larger than the maximum).  Snap to the maximum.
      visibleFraction = 1;
    }

    assert(visibleFraction >= 0);
    assert(visibleFraction <= 1);
    return visibleFraction;
  }

  /// The visible portion of the widget on main axis, in the viewport coordinates.
  RangeValues get visibleRange {
    var axis = axisDirectionToAxis(constraints.axisDirection);
    if (axis == Axis.horizontal) {
      return RangeValues(
        max(offset, 0),
        min(offset + size.width, constraints.viewportMainAxisExtent),
      );
    } else {
      return RangeValues(
        max(offset, 0),
        min(offset + size.height, constraints.viewportMainAxisExtent),
      );
    }
  }

  /// Returns true if the specified [VisibilityInfo] object has equivalent
  /// visibility to this one.
  bool matchesVisibility(ItemVisibilityInfo info) {
    // We don't override `operator ==` so that object equality can be separate
    // from whether two [VisibilityInfo] objects are sufficiently similar
    // that we don't need to fire callbacks for both.  This could be pertinent
    // if other properties are added.
    return size == info.size && constraints == info.constraints && offset == info.offset;
  }

  @override
  String toString() {
    return 'VisibilityInfo(size: $size offset: $offset)';
  }

  @override
  int get hashCode => Object.hash(constraints, size, offset);

  @override
  bool operator ==(Object other) {
    return other is ItemVisibilityInfo &&
        other.constraints == constraints &&
        other.size == size &&
        other.offset == offset;
  }
}

const _kDefaultTolerance = 0.01;