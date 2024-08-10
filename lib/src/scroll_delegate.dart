import 'package:flutter/widgets.dart';
import 'package:recycler_list/recycler_list.dart';
import 'package:recycler_list/src/sliver_multi_box_adaptor.dart';

/// Add item type support
mixin ItemTyper {
  ItemType? itemType;
}

/// Add visibility change support
mixin ItemVisibility {
  OnVisibilityChanged? childVisibilityChanged;
}

typedef ChildCountFixer = int Function(int childCount);

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
  @protected
  ValueNotifier<int>? childCountNotifier;

  /// Fix the child count, for example, when has separator
  @protected
  ChildCountFixer? childCountFixer;

  int? _childCount;

  @override
  int? get childCount => _childCount ?? super.childCount;

  void listenForItemCountChanges(RenderObject renderObject) {
    _updateChildCount();
    childCountNotifier?.removeListener(_updateChildCount);
    childCountNotifier?.addListener(_updateChildCount);
    childCountNotifier?.removeListener(renderObject.markNeedsLayoutForSizedByParentChange);
    childCountNotifier?.addListener(renderObject.markNeedsLayoutForSizedByParentChange);
  }

  void stopListeningForItemCountChanges(RenderObject renderObject) {
    childCountNotifier?.removeListener(renderObject.markNeedsLayoutForSizedByParentChange);
    childCountNotifier?.removeListener(_updateChildCount);
  }

  void _updateChildCount() {
    if (childCountNotifier == null) {
      return;
    }
    if (childCountFixer == null) {
      _childCount = childCountNotifier?.value;
    } else {
      _childCount = childCountFixer?.call(childCountNotifier!.value);
    }
  }
}

class TypedSliverChildBuilderDelegate extends SliverChildBuilderDelegate
    with ItemTyper, ItemVisibility, DataSetAppend {
  TypedSliverChildBuilderDelegate(
    super.builder, {
    ItemType? itemType,
    OnVisibilityChanged? childVisibilityChanged,
    super.findChildIndexCallback,
    super.childCount,
    ValueNotifier<int>? childCountNotifier,
    ChildCountFixer? childCountFixer,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
  }) {
    super.itemType = itemType;
    super.childCountNotifier = childCountNotifier;
    super.childCountFixer = childCountFixer;
    super.childVisibilityChanged = childVisibilityChanged;
  }
}

class TypedSliverChildListDelegate extends SliverChildListDelegate
    with ItemTyper, ItemVisibility {
  TypedSliverChildListDelegate(
    super.children, {
    ItemType? itemType,
    OnVisibilityChanged? childVisibilityChanged,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
  }) {
    super.itemType = itemType;
    super.childVisibilityChanged = childVisibilityChanged;
  }
}