import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'sliver.dart';
import 'sliver_list.dart';
import 'scroll_delegate.dart';

class RecyclerListView extends ListView {

  final ItemType? itemType;

  @override
  final SliverChildDelegate childrenDelegate;

  /// Same as [ListView] but with a [itemType] parameter.
  RecyclerListView({
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
    super.itemExtentBuilder,
    super.prototypeItem,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    List<Widget> children = const <Widget>[],
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  })  : assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        childrenDelegate = TypedSliverChildListDelegate(
          children,
          itemType: itemType,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          semanticChildCount: semanticChildCount ?? children.length,
        );

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
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    ValueNotifier<int>? itemCountNotifier,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  })  : assert(itemCount == null || itemCount >= 0),
        assert(semanticChildCount == null || semanticChildCount <= itemCount!),
        assert(
          (itemExtent == null && prototypeItem == null) ||
          (itemExtent == null && itemExtentBuilder == null) ||
          (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        childrenDelegate = TypedSliverChildBuilderDelegate(
          itemBuilder,
          itemType: itemType != null ? (int index) {
            final count = itemCountNotifier?.value ?? itemCount;
            if (count != null && index >= count) {
              return null;
            }
            return itemType.call(index);
          } : null,
          itemCountNotifier: itemCountNotifier,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          semanticChildCount: semanticChildCount ?? itemCount,
        );

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
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    ValueNotifier<int>? itemCountNotifier,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  })  : assert(itemCount >= 0),
        childrenDelegate = TypedSliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            if (index.isEven) {
              return itemBuilder(context, itemIndex);
            }
            return separatorBuilder(context, itemIndex);
          },
          itemType: itemType != null ? (int index) {
            if (index.isOdd) {
              return 'separator';
            }
            final count = itemCountNotifier?.value ?? itemCount;
            final itemIndex = index ~/ 2;
            return itemIndex <= count ? itemType.call(itemIndex) : null;
          } : null,
          itemCountNotifier: itemCountNotifier,
          findChildIndexCallback: findChildIndexCallback,
          childCount: _computeActualChildCount(itemCount),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget widget, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        ),
        super(
          semanticChildCount: itemCount,
        );

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
    required this.childrenDelegate,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  })  : assert(
          childrenDelegate is ItemTyper,
          'childrenDelegate must mixin ItemTyper',
        ),
        super.custom(childrenDelegate: childrenDelegate);
  
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
    );
  }

  // Helper method to compute the actual child count for the separated constructor.
  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }
}


class RecyclerSliverList extends SliverList {
  /// Creates a sliver that places box children in a linear array.
  const RecyclerSliverList({
    super.key,
    required super.delegate,
  });
  
  /// Same as [SliverList]
  RecyclerSliverList.builder({
    super.key,
    required super.itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.builder();

  /// Same as [SliverList]
  RecyclerSliverList.separated({
    super.key,
    required super.itemBuilder,
    super.findChildIndexCallback,
    required super.separatorBuilder,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.separated();

  /// Same as [SliverList]
  RecyclerSliverList.list({
    super.key,
    required super.children,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : super.list();

  @override
  SliverMultiBoxAdaptorElement createElement() => RecyclerSliverMultiBoxAdaptorElement(
        this,
        replaceMovedChildren: true,
      );

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    final renderObject = RecyclerRenderSliverList(childManager: element);
    _listenForItemCountChanges(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    _listenForItemCountChanges(renderObject);
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    _stopListeningForItemCountChanges(renderObject);
    super.didUnmountRenderObject(renderObject);
  }

  void _listenForItemCountChanges(RenderObject renderObject) {
    if (delegate is DataSetAppend) {
      final dataSetAppend = this.delegate as DataSetAppend;
      dataSetAppend.itemCountNotifier
          ?.removeListener(renderObject.markNeedsLayoutForSizedByParentChange);
      dataSetAppend.itemCountNotifier
          ?.addListener(renderObject.markNeedsLayoutForSizedByParentChange);
    }
  }

  void _stopListeningForItemCountChanges(RenderObject renderObject) {
    if (delegate is DataSetAppend) {
      (delegate as DataSetAppend)
          .itemCountNotifier
          ?.removeListener(renderObject.markNeedsLayoutForSizedByParentChange);
    }
  }
}