// ignore_for_file: avoid_print

bool debugRecyclerList = false;

/// For debugger RecyclerList
class Logger {
  static RecyclerListLog _log = RecyclerListLogImpl();

  static void custom(RecyclerListLog? log) {
    _log = log ?? RecyclerListLogImpl();
  }

  static void d(String msg) {
    _log.d(msg);
  }

  static void i(String msg) {
    _log.i(msg);
  }

  static void w(String msg) {
    _log.w(msg);
  }

  static void e(String msg, Exception? e) {
    _log.e(msg, e);
  }
}

abstract class RecyclerListLog {
  void d(String msg);
  void i(String msg);
  void w(String msg);
  void e(String msg, Exception? e);
}

class RecyclerListLogImpl implements RecyclerListLog {

  @override
  void d(String msg) {
    print(msg);
  }

  @override
  void i(String msg) {
    print(msg);
  }

  @override
  void w(String msg) {
    print(msg);
  }

  @override
  void e(String msg, Exception? e) {
    if (e == null) {
      print(msg);
    } else {
      print("$msg $e");
    }
  }
}