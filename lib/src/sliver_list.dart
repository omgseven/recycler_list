import 'package:flutter/rendering.dart';

import 'sliver_multi_box_adaptor.dart';

class RecyclerRenderSliverList extends RenderSliverList with RecyclerRenderSliverMultiBoxAdaptorMixin {
  RecyclerRenderSliverList({required super.childManager});
}
