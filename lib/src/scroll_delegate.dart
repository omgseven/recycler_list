import 'package:flutter/widgets.dart';
import 'package:recycler_list/recycler_list.dart';

/// Add item type support
mixin ItemTyper {
  ItemType? itemType;
}

class TypedSliverChildBuilderDelegate extends SliverChildBuilderDelegate with ItemTyper {
  TypedSliverChildBuilderDelegate(super.builder, {
    ItemType? itemType,
    super.findChildIndexCallback,
    super.childCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
  }) {
    super.itemType = itemType;
  }
}

class TypedSliverChildListDelegate extends SliverChildListDelegate with ItemTyper {
  TypedSliverChildListDelegate(super.builder, {
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