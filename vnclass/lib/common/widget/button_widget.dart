import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.title,
    this.ontap,
    this.color,
    this.child, // Thêm tham số child để hỗ trợ nội dung tùy chỉnh (ví dụ: loading)
  });

  final String title;
  final Function()? ontap;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDisabled = ontap == null; // Kiểm tra trạng thái vô hiệu hóa

    return Material(
      elevation: 0, // Điều chỉnh elevation nếu cần
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withOpacity(0.3), // Hiệu ứng ripple
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 16), // Tăng padding cho thoáng
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDisabled
                ? Colors.grey.shade400 // Màu khi vô hiệu hóa
                : (color ?? ColorApp.primaryColor), // Giữ màu cũ nếu có
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child ??
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey.shade700 : Colors.white,
                ),
              ),
        ),
      ),
    );
  }
}
