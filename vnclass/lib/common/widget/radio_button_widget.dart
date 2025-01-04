import 'package:flutter/material.dart';

class RadioButtonWidget extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const RadioButtonWidget(
      {super.key, required this.options, required this.onChanged});

  @override
  _RadioButtonWidgetState createState() => _RadioButtonWidgetState();
}

class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return ListTile(
          title: Text(option),
          leading: Radio<String>(
            value: option,
            groupValue: _selectedOption,
            onChanged: (String? value) {
              setState(() {
                _selectedOption = value;
              });
              widget.onChanged(value);
            },
          ),
        );
      }).toList(),
    );
  }
}
