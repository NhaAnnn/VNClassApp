import 'package:flutter/material.dart';

class DropMenuWidget<T> extends StatefulWidget {
  const DropMenuWidget({
    super.key,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.hintText,
    this.fillColor = Colors.white, // Nền trắng mặc định
    this.borderColor = const Color(0xFF666666), // Viền xám đen đậm hơn
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
    this.enabled = true,
  });

  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final Color? fillColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  State<DropMenuWidget<T>> createState() => _DropMenuWidgetState<T>();
}

class _DropMenuWidgetState<T> extends State<DropMenuWidget<T>> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  @override
  void didUpdateWidget(DropMenuWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem) {
      setState(() {
        _selectedItem = widget.selectedItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.enabled
            ? widget.fillColor
            : Colors.grey.shade200, // Nền thay đổi khi disabled
        borderRadius: BorderRadius.circular(12), // Bo góc mềm mại
        border: Border.all(
          color: widget.enabled
              ? widget.borderColor ?? const Color(0xFF666666) // Viền xám đen
              : Colors.grey.shade400, // Viền nhạt hơn khi disabled
          width: 1.0, // Mảnh hơn
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Bóng đổ rất nhẹ
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: _selectedItem,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.hintText ?? 'Chọn một mục',
              style: widget.textStyle?.copyWith(
                    color: Colors.grey.shade500, // Hint nhạt hơn, tinh tế
                    fontWeight: FontWeight.w400, // Nhẹ hơn khi là hint
                  ) ??
                  TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.arrow_drop_down_rounded, // Icon tròn trịa hơn
              color: widget.enabled
                  ? const Color(0xFF1976D2)
                  : Colors.grey.shade400, // Màu icon thay đổi
              size: 26, // Tăng nhẹ kích thước
            ),
          ),
          dropdownColor: Colors.white, // Nền menu thả trắng
          borderRadius: BorderRadius.circular(12), // Bo góc menu thả
          elevation: 3, // Bóng đổ nhẹ hơn, tinh tế
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
          focusColor: Colors.transparent, // Loại bỏ màu focus mặc định
          onChanged: widget.enabled
              ? (T? newValue) {
                  setState(() {
                    _selectedItem = newValue;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
                  }
                }
              : null,
          items: widget.items.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  value.toString(),
                  style: widget.textStyle?.copyWith(
                        color: widget.enabled
                            ? Colors.black87
                            : Colors
                                .grey.shade600, // Màu chữ thay đổi khi disabled
                      ) ??
                      TextStyle(
                        fontSize: 16,
                        color: widget.enabled
                            ? Colors.black87
                            : Colors
                                .grey.shade600, // Màu chữ thay đổi khi disabled
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
