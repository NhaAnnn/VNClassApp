import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageHelper {
  LocalStorageHelper._internal();
  static final LocalStorageHelper _shared = LocalStorageHelper._internal();

  factory LocalStorageHelper() {
    return _shared;
  }

  Box<dynamic>? hiveBox;

  static Future<void> initLocalStorageHelper() async {
    await Hive.initFlutter(); // Chỉ khởi tạo Hive
  }

  static Future<void> openBoxIfNeeded() async {
    if (_shared.hiveBox == null || !_shared.hiveBox!.isOpen) {
      _shared.hiveBox = await Hive.openBox('StuApp');
      print('Box StuApp size: ${Hive.box('StuApp').length} keys');
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
