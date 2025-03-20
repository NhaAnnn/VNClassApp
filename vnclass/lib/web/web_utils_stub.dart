// lib/web/web_utils_stub.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(List<int> bytes, String fileName) async {
  final directory = await getExternalStorageDirectory();
  final path = '${directory!.path}/$fileName';
  final file = File(path);
  await file.writeAsBytes(bytes);
}
