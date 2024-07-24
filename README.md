# recycler_list

RecyclerList is a Flutter package designed to provide an efficient way to create a list of items that can be recycled, 
similar to the RecyclerView in Android. This package aims to optimize performance by reusing item views as much as possible, 
reducing the need to inflate and layout new views as users scroll through the list. 
When an item is reused, it would be updated with new widget, like `setState()`.

## Features

- Efficient item recycling to improve scroll performance in long lists.
- Easy to use API, similar to the familiar `ListView.builder` in Flutter.
- Customizable item types for complex list structures.
- Support for dynamic item heights.

## Getting Started

To use RecyclerList in your Flutter project, add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  recycler_list: ^latest_version
```

## Usage

Here is a simple example of how to use RecyclerList in your app:

```dart
import 'package:flutter/material.dart';
import 'package:recycler_list/recycler_list.dart';

class MyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecyclerList Example'),
      ),
      body: RecyclerListView.builder(
        cacheExtent: 10,
        itemCount: 1000,
        itemType: (index) {
          return index % 2;
        },
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}
```

## Customization

RecyclerList determines the type of an item based on the return value of the `itemType` function. 
Items of different types are cached and recycled separately. 
If your list contains multiple item types, you can specify them using the `itemType` parameter.

For better performance, it is recommended to ensure that same item types have same widget tree structure.

The time taken to reuse an item is very related to the total number of widgets in the item's sub widget tree. 
To optimize recycling efficiency, it is advisable to minimize the complexity of the widget tree for each item type. 
This ensures faster updates and smoother scrolling performance.

## Contributing

Contributions are welcome! 
If you find a bug or would like to contribute to the project, feel free to create an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

