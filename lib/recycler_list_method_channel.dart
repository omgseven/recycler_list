import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'recycler_list_platform_interface.dart';

/// An implementation of [RecyclerListPlatform] that uses method channels.
class MethodChannelRecyclerList extends RecyclerListPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('recycler_list');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
