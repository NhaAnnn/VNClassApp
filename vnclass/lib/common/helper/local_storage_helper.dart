import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageHelper {
  LocalStorageHelper._internal();
  static final LocalStorageHelper _shared = LocalStorageHelper._internal();

  factory LocalStorageHelper() {
    return _shared;
  }

  Box<dynamic>? hiveBox;

  static Future<void> initLocalStorageHelper() async {
    final start = DateTime.now();
    await Hive.initFlutter();
    print(
        'Hive.initFlutter took: ${DateTime.now().difference(start).inMilliseconds}ms');
  }

  static Future<void> openBoxIfNeeded() async {
    if (_shared.hiveBox == null || !_shared.hiveBox!.isOpen) {
      final start = DateTime.now();
      _shared.hiveBox = await Hive.openBox('StuApp');
      print(
          'Hive.openBox took: ${DateTime.now().difference(start).inMilliseconds}ms');
    }
  }

  static Future<dynamic> getValue(String key) async {
    await openBoxIfNeeded();
    return _shared.hiveBox?.get(key);
  }

  static Future<void> setValue(String key, dynamic val) async {
    await openBoxIfNeeded();
    await _shared.hiveBox?.put(key, val);
  }
}
