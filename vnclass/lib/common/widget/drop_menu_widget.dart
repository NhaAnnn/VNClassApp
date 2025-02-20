import 'package:flutter/material.dart';

class DropMenuWidget<T> extends StatefulWidget {
  const DropMenuWidget({
    super.key,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.hintText,
    this.fillColor, // màu nền
    this.borderColor, // màu viền
    this.textStyle, // kiểu chữ
    this.enabled = true, // thêm enabled (mặc định là true)
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
      // Sử dụng màu nền nếu có
      decoration: BoxDecoration(
        color: widget.fillColor,
        border: Border.all(
          color: widget.borderColor ?? Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: DropdownButton<T>(
        underline: const SizedBox(),
        elevation: 100,
        value: _selectedItem,
        hint: Center(
          child: Text(
            widget.hintText ?? 'Chọn một mục',
            style: widget.textStyle ??
                const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: const Color.fromARGB(255, 226, 226, 226),
        onChanged: widget.enabled
            ? (T? newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(newValue);
                }
              }
            : null, // Nếu không enabled, onChanged = null
        items: widget.items.map<DropdownMenuItem<T>>((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Center(
              child: Text(
                value.toString(),
                style: widget.textStyle ??
                    const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
