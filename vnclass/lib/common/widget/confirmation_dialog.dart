import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    String title = 'Xác nhận',
    String message = 'Bạn có chắc chắn muốn thực hiện hành động này?',
    String confirmText = 'Đồng ý',
    String cancelText = 'Hủy',
    Color confirmColor = Colors.redAccent,
    Color cancelColor = Colors.grey,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bo góc dialog
          ),
          elevation: 8, // Độ cao bóng đổ
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Khoảng cách bên trong
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Giới hạn kích thước theo nội dung
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                    height: 12), // Khoảng cách giữa tiêu đề và nội dung
                // Nội dung
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4, // Độ cao dòng cho dễ đọc
                  ),
                ),
                const SizedBox(height: 24), // Khoảng cách trước nút
                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nút Hủy
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: cancelColor.withOpacity(0.5)),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: 16,
                          color: cancelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Khoảng cách giữa hai nút
                    // Nút Đồng ý
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor, // Màu nền nút
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
