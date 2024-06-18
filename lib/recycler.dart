import 'package:flutter/foundation.dart';

/// Recycle items to reduce creating and destroying.
class Recycler<T> {
  static bool enableWarning = kDebugMode;

  final _caches = <Object, List<T>>{};

  int _counter = 0;

  Map<Object, List<T>> get caches => _caches;

  void recycle(Object type, T child) {
    _caches.putIfAbsent(type, () => []).add(child);
    _counter++;
    assert(!enableWarning || _counter <= 100,
        'Recycler has too many items: $_counter, please ensure "itemType" works correctly.');
  }

  T? obtain(Object type) {
    final List<T>? caches = _caches[type];
    if (caches != null && caches.isNotEmpty) {
      final cache = caches.removeLast();
      if (cache != null) {
        _counter--;
        assert(_counter >= 0);
      }
      return cache;
    }
    return null;
  }
}