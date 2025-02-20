import 'package:flutter/material.dart';

enum RadioLayout { horizontal, vertical }

class RadioButtonWidget extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;
  final RadioLayout layout;
  final Color? activeColor;
  final TextStyle? labelStyle;
  final bool enabled; // thêm enabled

  const RadioButtonWidget({
    super.key,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.layout = RadioLayout.vertical,
    this.activeColor,
    this.labelStyle,
    this.enabled = true, // mặc định cho phép chỉnh sửa
  });

  @override
  _RadioButtonWidgetState createState() => _RadioButtonWidgetState();
}

class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layout == RadioLayout.horizontal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.options.map((option) {
          return Row(
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
                activeColor: widget.activeColor,
              ),
              Text(option, style: widget.labelStyle),
            ],
          );
        }).toList(),
      );
    } else {
      return Column(
        children: widget.options.map((option) {
          return Row(
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
                activeColor: widget.activeColor,
              ),
              Text(option, style: widget.labelStyle),
            ],
          );
        }).toList(),
      );
    }
  }
}
