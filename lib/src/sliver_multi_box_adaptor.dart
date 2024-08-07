import 'package:flutter/rendering.dart';


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
