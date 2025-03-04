import 'package:flutter/material.dart';

class CustomDialogWidgetS {
  static void showConfirmationDialogW(
    BuildContext context,
    String title, {
    VoidCallback? onTapOK,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true, // Cho phép đóng dialog khi nhấn ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bo tròn viền dialog
          ),
          elevation: 4,
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(0), // Loại bỏ padding mặc định
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Giới hạn chiều cao dialog tối thiểu
            children: [
              // Tiêu đề
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1976D2), // Màu xanh đậm cho header
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12), // Bo góc trên
                  ),
                ),
                width: double.infinity,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Nội dung (có thể thêm nếu cần)
              const SizedBox(height: 20),
              // Nút hành động
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (onTapOK != null) {
                            onTapOK();
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Đồng ý',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
