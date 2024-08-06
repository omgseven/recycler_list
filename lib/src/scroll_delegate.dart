import 'package:flutter/widgets.dart';
import 'package:recycler_list/recycler_list.dart';

/// Add item type support
mixin ItemTyper {
  ItemType? itemType;
}

/// Add data set append support
///
/// Optimize the appended content of the data set.
/// For example, when loading more data, setState() can be omitted.
mixin DataSetAppend on SliverChildBuilderDelegate {

  /// The number of children in the data set.
  /// When listView reach end, notification from [itemCountNotifier] will trigger
  /// listView to relayout, which is helpful for the list to layout new items
  /// without rebuilding the entire list.
  /// see [RecyclerSliverList]
  ValueNotifier<int>? itemCountNotifier;

  @override
  int? get childCount => itemCountNotifier?.value ?? super.childCount;
}

class TypedSliverChildBuilderDelegate extends SliverChildBuilderDelegate with ItemTyper, DataSetAppend {
  TypedSliverChildBuilderDelegate(
    super.builder, {
    ItemType? itemType,
    ValueNotifier<int>? itemCountNotifier,
    super.findChildIndexCallback,
    super.childCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
  }) {
    super.itemType = itemType;
    super.itemCountNotifier = itemCountNotifier;
  }
}

class TypedSliverChildListDelegate extends SliverChildListDelegate with ItemTyper {
  TypedSliverChildListDelegate(
    super.children, {
    ItemType? itemType,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
  }) {
    super.itemType = itemType;
  }
}