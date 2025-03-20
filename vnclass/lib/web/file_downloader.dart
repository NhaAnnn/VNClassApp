// lib/web/file_downloader.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectory;

void downloadFile(List<int> bytes, String fileName, {required bool isWeb}) {
  if (isWeb) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    _downloadFileMobile(bytes, fileName);
  }
}

Future<void> _downloadFileMobile(List<int> bytes, String fileName) async {
  final directory = await getExternalStorageDirectory();
  final path = '${directory!.path}/$fileName';
  final file = File(path);
  await file.writeAsBytes(bytes);
}
