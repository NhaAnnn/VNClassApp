import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';

class ItemClassmodels extends StatelessWidget {
  const ItemClassmodels({super.key, required this.classMistakeModel});

  final ClassMistakeModel classMistakeModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Lop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      classMistakeModel.className,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Lop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      classMistakeModel.className,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Lop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      classMistakeModel.className,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Lop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      classMistakeModel.className,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Lop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      classMistakeModel.className,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Lop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      classMistakeModel.className,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              FontAwesomeIcons.arrowRight,
              size: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
