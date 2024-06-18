
import 'recycler_list_platform_interface.dart';

class RecyclerList {
  Future<String?> getPlatformVersion() {
    return RecyclerListPlatform.instance.getPlatformVersion();
  }
}
