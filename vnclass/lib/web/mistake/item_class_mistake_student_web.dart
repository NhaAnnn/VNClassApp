import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_type_mistake_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_view_mistake_page.dart';
import 'package:vnclass/web/mistake/mistake_type_mistake_page_web.dart';
import 'package:vnclass/web/mistake/mistake_view_mistake_page_web.dart';

class ItemClassMistakeStudentWeb extends StatelessWidget {
  const ItemClassMistakeStudentWeb({
    super.key,
    required this.studentDetailModel,
    this.month,
    this.onRefresh,
  });

  final StudentDetailModel studentDetailModel;
  final String? month;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                studentDetailModel.idStudent,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Text(
                studentDetailModel.nameStudent,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  studentDetailModel.numberOfErrors,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD32F2F)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    MistakeViewMistakePageWeb.routeName,
                    arguments: {
                      'studentDetailModel': studentDetailModel,
                      'month': month
                    },
                  );
                  if (onRefresh != null && context.mounted) {
                    await onRefresh!(); // Gọi hàm bất đồng bộ
                  }
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(FontAwesomeIcons.eye,
                        size: 18, color: Color(0xFF0288D1)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    MistakeTypeMistakePageWeb.routeName,
                    arguments: studentDetailModel,
                  );
                  if (onRefresh != null && context.mounted) {
                    await onRefresh!(); // Gọi hàm bất đồng bộ
                  }
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(FontAwesomeIcons.pen,
                        size: 18, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
