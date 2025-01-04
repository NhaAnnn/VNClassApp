import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/student_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_type_mistake_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_view_mistake_page.dart';

class ItemClassMistakeStudent extends StatelessWidget {
  const ItemClassMistakeStudent({
    super.key,
    required this.studentMistakeModel,
  });
  final StudentMistakeModel studentMistakeModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withAlpha(50), // Border color
          width: 2, // Border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 3), // Changes the position of the shadow
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          top: 16,
          bottom: 16,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                studentMistakeModel.idStudent,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 5,
              child: Text(
                studentMistakeModel.nameStudent,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 1,
              child: Text(
                studentMistakeModel.numberOfErrors,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushNamed(MistakeViewMistakePage.routeName),
                child: Icon(
                  FontAwesomeIcons.eye,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushNamed(MistakeTypeMistakePage.routeName),
                child: Icon(
                  FontAwesomeIcons.pen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
