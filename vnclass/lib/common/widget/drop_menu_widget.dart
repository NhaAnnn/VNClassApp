import 'package:flutter/material.dart';

class DropMenuWidget<T> extends StatefulWidget {
  const DropMenuWidget({
    super.key,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.hintText,
  });

  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final String? hintText;

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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2), // Màu và độ dày viền
        borderRadius: BorderRadius.circular(4.0), // Độ bo tròn của viền
      ),
      child: DropdownButton<T>(
        underline: SizedBox(),
        elevation: 100,
        value: _selectedItem,
        hint: Center(
          child: Text(
            widget.hintText ?? 'Chọn một mục',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: const Color.fromARGB(255, 226, 226, 226),
        onChanged: (T? newValue) {
          setState(() {
            _selectedItem = newValue;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(newValue);
          }
        },
        items: widget.items.map<DropdownMenuItem<T>>((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
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
