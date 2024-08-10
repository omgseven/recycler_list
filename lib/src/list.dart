import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

import 'sliver.dart';
import 'sliver_list.dart';
import 'scroll_delegate.dart';
import 'sliver_multi_box_adaptor.dart';

class RecyclerListView extends ListView {

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
    ItemType? itemType,
    OnVisibilityChanged? childVisibilityChanged,
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
          childVisibilityChanged: childVisibilityChanged,
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
    ItemType? itemType,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    ValueNotifier<int>? childCountNotifier,
    OnVisibilityChanged? childVisibilityChanged,
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
            final count = childCountNotifier?.value ?? itemCount;
            if (count != null && index >= count) {
              return null;
            }
            return itemType.call(index);
          } : null,
          childVisibilityChanged: childVisibilityChanged,
          childCountNotifier: childCountNotifier,
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
    ItemType? itemType,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    ValueNotifier<int>? childCountNotifier,
    OnVisibilityChanged? childVisibilityChanged,
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
            final count = childCountNotifier?.value ?? itemCount;
            final itemIndex = index ~/ 2;
            return itemIndex <= count ? itemType.call(itemIndex) : null;
          } : null,
          childVisibilityChanged: childVisibilityChanged != null ? (int index, VisibilityInfo info) {
            if (index.isOdd) {
              return;
            }
            final itemIndex = index ~/ 2;
            final count = childCountNotifier?.value ?? itemCount;
            if (itemIndex <= count) {
              childVisibilityChanged(itemIndex, info);
            }
          } : null,
          childCountNotifier: childCountNotifier,
          childCountFixer: _computeActualChildCountWithSeparator,
          findChildIndexCallback: findChildIndexCallback,
          childCount: _computeActualChildCountWithSeparator(itemCount),
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
}

// Helper method to compute the actual child count for the separated constructor.
int _computeActualChildCountWithSeparator(int itemCount) {
  return math.max(0, itemCount * 2 - 1);
}

/// Same as [SliverList] but with a few additional features.
///
/// [SliverListRecycler] provides recycler support.
/// [SliverListDataSetAppend] avoids rebuilding the entire list when the child count changes.
/// [SliverListVisibilityChange] provides visibility change callback.
class RecyclerSliverList extends SliverList
    with
        SliverListRecycler,
        SliverListDataSetAppend,
        SliverListVisibilityChange {
  /// Creates a sliver that places box children in a linear array.
  const RecyclerSliverList({
    super.key,
    required super.delegate,
  });

  /// Same as [SliverList]
  RecyclerSliverList.builder({
    super.key,
    ItemType? itemType,
    OnVisibilityChanged? childVisibilityChanged,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(delegate: TypedSliverChildBuilderDelegate(
          itemBuilder,
          itemType: itemType,
          childVisibilityChanged: childVisibilityChanged,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ));

  /// Same as [SliverList]
  RecyclerSliverList.separated({
    super.key,
    ItemType? itemType,
    OnVisibilityChanged? childVisibilityChanged,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required NullableIndexedWidgetBuilder separatorBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(delegate: TypedSliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            final Widget? widget;
            if (index.isEven) {
              widget = itemBuilder(context, itemIndex);
            } else {
              widget = separatorBuilder(context, itemIndex);
              assert(() {
                if (widget == null) {
                  throw FlutterError('separatorBuilder cannot return null.');
                }
                return true;
              }());
            }
            return widget;
          },
          itemType: itemType != null ? (int index) {
            if (index.isOdd) {
              return 'separator';
            }
            return itemType.call(index ~/ 2);
          } : null,
          childVisibilityChanged: childVisibilityChanged != null ? (int index, VisibilityInfo info) {
            if (index.isOdd) {
              return;
            }
            final itemIndex = index ~/ 2;
            childVisibilityChanged(itemIndex, info);
          } : null,
          childCountFixer: _computeActualChildCountWithSeparator,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount == null ? null : _computeActualChildCountWithSeparator(itemCount),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget _, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        ));

  /// Same as [SliverList]
  RecyclerSliverList.list({
    super.key,
    required List<Widget> children,
    ItemType? itemType,
    OnVisibilityChanged? childVisibilityChanged,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(delegate: TypedSliverChildListDelegate(
    children,
    itemType: itemType,
    childVisibilityChanged: childVisibilityChanged,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addRepaintBoundaries: addRepaintBoundaries,
    addSemanticIndexes: addSemanticIndexes,
  ));

}

/// A mixin that adds recycler support to [SliverMultiBoxAdaptorWidget].
///
/// see [RecyclerSliverMultiBoxAdaptorElement]
/// see [RecyclerRenderSliverList]
mixin SliverListRecycler on SliverMultiBoxAdaptorWidget {

  @override
  SliverMultiBoxAdaptorElement createElement() => RecyclerSliverMultiBoxAdaptorElement(
    this,
    replaceMovedChildren: true,
  );

  @override
  RecyclerRenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    final renderObject = RecyclerRenderSliverList(childManager: element);
    return renderObject;
  }
}

/// A mixin that triggers a layout when the child count changes.
///
/// This mixin is useful to avoid rebuilding the entire list when the child count changes.
mixin SliverListDataSetAppend on SliverListRecycler {

  DataSetAppend? get dataSetAppend =>
      delegate is DataSetAppend ? delegate as DataSetAppend : null;

  @override
  RecyclerRenderSliverList createRenderObject(BuildContext context) {
    var renderObject = super.createRenderObject(context);
    dataSetAppend?.listenForItemCountChanges(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, covariant RecyclerRenderSliverList renderObject) {
    super.updateRenderObject(context, renderObject);
    dataSetAppend?.listenForItemCountChanges(renderObject);
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    dataSetAppend?.stopListeningForItemCountChanges(renderObject);
    super.didUnmountRenderObject(renderObject);
  }
}

/// A mixin that provides visibility change callback for [RecyclerRenderSliverList].
mixin SliverListVisibilityChange on SliverListRecycler {

  ItemVisibility? get itemVisibility =>
      delegate is ItemVisibility ? delegate as ItemVisibility : null;

  @override
  RecyclerRenderSliverList createRenderObject(BuildContext context) {
    var renderObject = super.createRenderObject(context);
    _setChildVisibilityChanged(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, covariant VisibilityChangeMixin renderObject) {
    super.updateRenderObject(context, renderObject);
    _setChildVisibilityChanged(renderObject);
  }

  void _setChildVisibilityChanged(VisibilityChangeMixin renderObject) {
    renderObject.childVisibilityChanged = itemVisibility?.childVisibilityChanged;
  }
}