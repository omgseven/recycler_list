import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:recycler_list/recycler_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static const initialItemCount = 100;
  final itemCountNotifier = ValueNotifier<int>(0);
  final testData = List.generate(initialItemCount, (index) => 'item $index');
  Timer? timer;

  @override
  void initState() {
    super.initState();
    itemCountNotifier.value = testData.length;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      testData.add('item ${testData.length}');
      itemCountNotifier.value = testData.length;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    itemCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: myList(),
        // body: sysList(),
      ),
    );
  }

  Widget myList() {
    return RecyclerListView.builder(
      cacheExtent: 10,
      itemCount: initialItemCount,
      itemType: (index) {
        return index % 2;
      },
      itemCountNotifier: itemCountNotifier,
      itemBuilder: (_, index) {
        Widget cur = Container(
          height: 100,
          alignment: Alignment.center,
          color: randomColor(min: 155, range: 100),
          child: Text('item $index'),
        );
        cur = TestWidget(child: cur);
        // 偶数项添加点击事件，保证与奇数项的item无法复用，验证是否复用正常（不会重复创建）
        if (index % 2 == 0) {
          cur = GestureDetector(
            onTap: () {
              print('tap $index');
            },
            child: cur,
          );
        }
        // cur = KeepAliveWrapper(child: cur);
        return cur;
      },
    );
  }

  Widget sysList() {
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (_, index) {
        return SizedBox(
          child: Text('item $index'),
        );
      },
    );
  }
}

class TestWidget extends SingleChildRenderObjectWidget {
  TestWidget({super.key, super.child}) {
    print('create TestWidget');
  }

  @override
  SingleChildRenderObjectElement createElement() {
    return TestElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TestRenderObject();
  }
}

class TestElement extends SingleChildRenderObjectElement {
  TestElement(super.widget) {
    print('create TestElement');
  }
}

class TestRenderObject extends RenderProxyBox {
  TestRenderObject([RenderBox? child]): super(child) {
    print('create TestRenderObject');
  }
}


class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    Key? key,
    this.keepAlive = true,
    required this.child,
  }) : super(key: key);
  final bool keepAlive;
  final Widget child;

  @override
  State createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if(oldWidget.keepAlive != widget.keepAlive) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

Color randomColor({int min = 155, int range = 100}) {
  final random = math.Random();
  assert(min >= 0 && min <= 255);
  assert(range >= 0 && range <= 255);
  assert(range + min <= 255);
  range = math.min(range, 255 - min);
  return Color.fromARGB(
    255,
    min + random.nextInt(range),
    min + random.nextInt(range),
    min + random.nextInt(range),
  );
}