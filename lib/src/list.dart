import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'sliver.dart';
import 'sliver_list.dart';

class RecyclerListView extends ListView {

  final ItemType? itemType;

  /// Same as [ListView] but with a [itemType] parameter.
  RecyclerListView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.itemExtentBuilder,
    super.prototypeItem,
    this.itemType,
    required super.itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }): super.builder();

  /// Same as [ListView] but with a [itemType] parameter.
  RecyclerListView.separated({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    this.itemType,
    required super.itemBuilder,
    super.findChildIndexCallback,
    required super.separatorBuilder,
    required super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super. addSemanticIndexes,
    super.cacheExtent,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super.separated();

  /// Same as [ListView] but with a [itemType] parameter.
  const RecyclerListView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    this.itemType,
    super.itemExtent,
    super.prototypeItem,
    super.itemExtentBuilder,
    required super.childrenDelegate,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super.custom();

  @override
  Widget buildChildLayout(BuildContext context) {
    // TODO: support itemExtent, itemExtentBuilder, prototypeItem
    // if (itemExtent != null) {
    //   return SliverFixedExtentList(
    //     delegate: childrenDelegate,
    //     itemExtent: itemExtent!,
    //   );
    // } else if (itemExtentBuilder != null) {
    //   return SliverVariedExtentList(
    //     delegate: childrenDelegate,
    //     itemExtentBuilder: itemExtentBuilder!,
    //   );
    // } else if (prototypeItem != null) {
    //   return SliverPrototypeExtentList(
    //     delegate: childrenDelegate,
    //     prototypeItem: prototypeItem!,
    //   );
    // }
    return RecyclerSliverList(
      delegate: childrenDelegate,
      itemType: itemType,
    );
  }
}


class RecyclerSliverList extends SliverList {
  /// Creates a sliver that places box children in a linear array.
  const RecyclerSliverList({
    super.key,
    required super.delegate,
    this.itemType,
  });

  final ItemType? itemType;

  /// Same as [SliverList] but with a [itemType] parameter.
  RecyclerSliverList.builder({
    super.key,
    required super.itemBuilder,
    super.findChildIndexCallback,
    this.itemType,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.builder();

  /// Same as [SliverList] but with a [itemType] parameter.
  RecyclerSliverList.separated({
    super.key,
    required super.itemBuilder,
    super.findChildIndexCallback,
    required super.separatorBuilder,
    this.itemType,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.separated();

  /// Same as [SliverList] but with a [itemType] parameter.
  RecyclerSliverList.list({
    super.key,
    required super.children,
    this.itemType,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.list();

  @override
  SliverMultiBoxAdaptorElement createElement() => RecyclerSliverMultiBoxAdaptorElement(
        this,
        replaceMovedChildren: true,
        itemType: itemType,
      );

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return RecyclerRenderSliverList(childManager: element);
  }
}
