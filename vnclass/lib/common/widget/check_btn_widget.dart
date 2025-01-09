import 'package:flutter/material.dart';

class CheckBoxWidget extends StatefulWidget {
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  const CheckBoxWidget({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  _CheckBoxWidgetState createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  final List<String> _selectedOptions = [];

  void _onCheckboxChanged(String option, bool? isChecked) {
    setState(() {
      if (isChecked == true) {
        _selectedOptions.add(option);
      } else {
        _selectedOptions.remove(option);
      }
    });
    widget.onChanged(_selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return Row(
          children: [
            Checkbox(
              value: _selectedOptions.contains(option),
              onChanged: (bool? isChecked) {
                _onCheckboxChanged(option, isChecked);
              },
            ),
            Text(option),
          ],
        );
      }).toList(),
    );
  }
}
