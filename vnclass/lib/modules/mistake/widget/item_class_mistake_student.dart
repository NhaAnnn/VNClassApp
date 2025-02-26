import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_type_mistake_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_view_mistake_page.dart';

class ItemClassMistakeStudent extends StatelessWidget {
  const ItemClassMistakeStudent({
    super.key,
    required this.studentDetailModel,
    this.month,
    this.onRefresh,
  });

  final StudentDetailModel studentDetailModel;
  final String? month;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          // Mã học sinh (căn trái)
          Expanded(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                studentDetailModel.idStudent,
                textAlign: TextAlign.left, // Căn trái
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Tên học sinh (căn trái)
          Expanded(
            flex: 5,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Text(
                studentDetailModel.nameStudent,
                textAlign: TextAlign.left, // Căn trái
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Số lỗi (giữ căn giữa)
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  studentDetailModel.numberOfErrors,
                  textAlign: TextAlign.center, // Giữ căn giữa
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
          // Icon Xem (giữ căn giữa)
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    MistakeViewMistakePage.routeName,
                    arguments: {
                      'studentDetailModel': studentDetailModel,
                      'month': month,
                    },
                  );
                  if (onRefresh != null && context.mounted) {
                    onRefresh!();
                  }
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.eye,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Icon Sửa (giữ căn giữa)
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  MistakeTypeMistakePage.routeName,
                  arguments: studentDetailModel,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.pen,
                      size: 16,
                      color: Colors.green,
                    ),
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
