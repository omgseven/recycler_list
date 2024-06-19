import 'package:flutter/rendering.dart';

import '../recycler_list.dart';

mixin RecyclerRenderSliverMultiBoxAdaptorMixin on RenderSliverMultiBoxAdaptor {

  void obtainChild(RenderBox child, int index) {
    assert((){
      if (debug) {
        print('RecyclerList >>>>>>>>>>> obtain $index');
      }
      return true;
    }());
    setupParentData(child);
    final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
    childParentData.index = index;

    final lastIndex = lastChild == null ? double.maxFinite : indexOf(lastChild!);
    var after = index > lastIndex ? lastChild : null;
    insert(child, after: after);
  }

  void recycleChild(RenderBox child) {
    assert((){
      if (debug) {
        final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
        print('RecyclerList <<<<<<<<<<< recycle ${childParentData.index}');
      }
      return true;
    }());
    remove(child);
  }
}
