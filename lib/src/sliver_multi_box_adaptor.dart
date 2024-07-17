import 'package:flutter/rendering.dart';


mixin RecyclerRenderSliverMultiBoxAdaptorMixin on RenderSliverMultiBoxAdaptor {

  void obtainChild(RenderBox child, int index) {
    setupParentData(child);
    final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
    childParentData.index = index;

    final lastIndex = lastChild == null ? double.maxFinite : indexOf(lastChild!);
    var after = index > lastIndex ? lastChild : null;
    insert(child, after: after);
  }

  void recycleChild(RenderBox child) {
    remove(child);
  }
}
