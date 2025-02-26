import 'package:flutter/material.dart';

enum RadioLayout { horizontal, vertical }

class RadioButtonWidget extends StatefulWidget {
  final List<String> options; // Danh sách các tùy chọn radio
  final ValueChanged<String?> onChanged; // Callback khi thay đổi lựa chọn
  final String? selectedValue; // Giá trị mặc định được chọn
  final RadioLayout layout; // Bố cục: ngang hoặc dọc
  final Color? activeColor; // Màu khi nút radio được chọn
  final TextStyle? labelStyle; // Kiểu chữ cho nhãn
  final bool enabled; // Trạng thái bật/tắt khả năng tương tác
  final double? radioSize; // Kích thước tùy chỉnh cho nút radio
  final EdgeInsets? padding; // Khoảng cách trong của mỗi mục

  const RadioButtonWidget({
    super.key,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.layout = RadioLayout.vertical,
    this.activeColor,
    this.labelStyle,
    this.enabled = true,
    this.radioSize = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  _RadioButtonWidgetState createState() => _RadioButtonWidgetState();
}

class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  String? _selectedOption; // Giá trị hiện tại được chọn

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedValue; // Khởi tạo giá trị ban đầu
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Kiểu chữ mặc định cho nhãn
    final defaultLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF263238),
      fontWeight: FontWeight.w500,
    );

    return widget.layout == RadioLayout.horizontal
        ? SingleChildScrollView(
            scrollDirection:
                Axis.horizontal, // Cho phép cuộn ngang nếu nội dung dài
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Chỉ chiếm không gian tối thiểu cần thiết
              children: widget.options
                  .map((option) => _buildRadioItem(option, defaultLabelStyle))
                  .toList(),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.options
                .map((option) => _buildRadioItem(option, defaultLabelStyle))
                .toList(),
          );
  }

  // Hàm xây dựng mỗi mục radio
  Widget _buildRadioItem(String option, TextStyle? defaultLabelStyle) {
    final isSelected =
        _selectedOption == option; // Kiểm tra xem mục này có được chọn không
    return GestureDetector(
      onTap: widget.enabled
          ? () {
              setState(() {
                _selectedOption = option; // Cập nhật giá trị được chọn
              });
              widget.onChanged(option); // Gọi callback để thông báo thay đổi
            }
          : null, // Nếu không bật thì không cho tương tác
      child: Container(
        margin: widget.layout == RadioLayout.horizontal
            ? const EdgeInsets.symmetric(
                horizontal: 4) // Giảm margin để tránh tràn
            : const EdgeInsets.symmetric(vertical: 4),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && widget.enabled
                ? const Color(0xFF1976D2)
                : const Color(
                    0xFFE0E0E0), // Viền xanh khi chọn, xám khi không chọn
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: option,
              groupValue: _selectedOption,
              onChanged: widget.enabled
                  ? (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                      widget.onChanged(value);
                    }
                  : null,
              activeColor: widget.activeColor ?? const Color(0xFF1976D2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ).groupValueScale(
                widget.radioSize ?? 20.0), // Điều chỉnh kích thước
            const SizedBox(width: 8),
            Flexible(
              // Sử dụng Flexible để nhãn co giãn vừa với không gian
              child: Text(
                option,
                style: widget.labelStyle ?? defaultLabelStyle,
                overflow: TextOverflow.ellipsis, // Cắt nhãn nếu quá dài
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension để điều chỉnh kích thước của Radio button
extension RadioExtension on Radio<String> {
  // Hàm mở rộng để áp dụng Transform.scale cho nút radio
  Widget groupValueScale(double size) {
    double scale = size / 24.0; // Tỷ lệ dựa trên kích thước mặc định (~24px)
    return Transform.scale(
      scale: scale,
      child: this,
    );
  }
}
