import 'dart:html' as html;
import 'package:flutter/services.dart';

Future<void> downloadTemplateForWeb(String fileName) async {
  String assetPath = 'assets/files/Lop_template.xlsx';
  try {
    // Read data from assets
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    final bytes =
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    // Create a Blob from the file data
    final blob = html.Blob([bytes]);

    // Create a URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element to facilitate download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName) // File name
      ..click(); // Trigger the download

    // Revoke the URL after download
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Lỗi khi tải mẫu: $e');
  }
}
