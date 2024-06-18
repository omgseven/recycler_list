import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'recycler_list_method_channel.dart';

abstract class RecyclerListPlatform extends PlatformInterface {
  /// Constructs a RecyclerListPlatform.
  RecyclerListPlatform() : super(token: _token);

  static final Object _token = Object();

  static RecyclerListPlatform _instance = MethodChannelRecyclerList();

  /// The default instance of [RecyclerListPlatform] to use.
  ///
  /// Defaults to [MethodChannelRecyclerList].
  static RecyclerListPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RecyclerListPlatform] when
  /// they register themselves.
  static set instance(RecyclerListPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
