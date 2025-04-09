import 'package:cloud_firestore/cloud_firestore.dart';
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
    this.isSearch,
  });

  final StudentDetailModel studentDetailModel;
  final String? month;
  final bool? isSearch;
  final Future<void> Function()?
      onRefresh; // Đổi VoidCallback thành Future<void> Function()

  Future<List<StudentDetailModel?>> fetchStudentMistakeClasses(
      String idClass) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', isEqualTo: idClass)
        .get();

    final data = await Future.wait(
      snapshot.docs.map((doc) => StudentDetailModel.fromFirestore(doc, month!)),
    );

    return data;
  }

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
      // child: Row(
      //   children: [
      //     Expanded(
      //       flex: 3,
      //       child: ConstrainedBox(
      //         constraints: const BoxConstraints(minWidth: 100),
      //         child: Text(
      //           studentDetailModel.idStudent,
      //           textAlign: TextAlign.left,
      //           style: const TextStyle(
      //               fontSize: 14,
      //               fontWeight: FontWeight.w600,
      //               color: Colors.black87),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 5,
      //       child: ConstrainedBox(
      //         constraints: const BoxConstraints(minWidth: 150),
      //         child: Text(
      //           studentDetailModel.nameStudent,
      //           textAlign: TextAlign.left,
      //           style: const TextStyle(
      //               fontSize: 14,
      //               fontWeight: FontWeight.w600,
      //               color: Colors.black87),
      //         ),
      //       ),
      //     ),
      //     if (isSearch == null) ...[
      //       Expanded(
      //         flex: 1,
      //         child: ConstrainedBox(
      //           constraints: const BoxConstraints(minWidth: 40),
      //           child: Container(
      //             padding:
      //                 const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      //             decoration: BoxDecoration(
      //               color: const Color(0xFFD32F2F).withOpacity(0.12),
      //               borderRadius: BorderRadius.circular(6),
      //             ),
      //             child: Text(
      //               studentDetailModel.numberOfErrors,
      //               textAlign: TextAlign.center,
      //               style: const TextStyle(
      //                   fontSize: 14,
      //                   fontWeight: FontWeight.w600,
      //                   color: Color(0xFFD32F2F)),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //     Expanded(
      //       flex: 1,
      //       child: ConstrainedBox(
      //         constraints: const BoxConstraints(minWidth: 36),
      //         child: GestureDetector(
      //           onTap: () async {
      //             await Navigator.pushNamed(
      //               context,
      //               MistakeViewMistakePage.routeName,
      //               arguments: {
      //                 'studentDetailModel': studentDetailModel,
      //                 'month': month
      //               },
      //             );
      //             if (onRefresh != null && context.mounted) {
      //               await onRefresh!(); // Gọi hàm bất đồng bộ
      //             }
      //           },
      //           child: Center(
      //             child: Container(
      //               padding: const EdgeInsets.all(6),
      //               decoration: BoxDecoration(
      //                 color: const Color(0xFF0288D1).withOpacity(0.15),
      //                 borderRadius: BorderRadius.circular(6),
      //               ),
      //               child: const Icon(FontAwesomeIcons.eye,
      //                   size: 18, color: Color(0xFF0288D1)),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: ConstrainedBox(
      //         constraints: const BoxConstraints(minWidth: 36),
      //         child: GestureDetector(
      //           onTap: () async {
      //             await Navigator.pushNamed(
      //               context,
      //               MistakeTypeMistakePage.routeName,
      //               arguments: studentDetailModel,
      //             );
      //             if (onRefresh != null && context.mounted) {
      //               await onRefresh!(); // Gọi hàm bất đồng bộ
      //             }
      //           },
      //           child: Center(
      //             child: Container(
      //               padding: const EdgeInsets.all(6),
      //               decoration: BoxDecoration(
      //                 color: const Color(0xFF2E7D32).withOpacity(0.15),
      //                 borderRadius: BorderRadius.circular(6),
      //               ),
      //               child: const Icon(FontAwesomeIcons.pen,
      //                   size: 18, color: Color(0xFF2E7D32)),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),

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
                  color: Colors.black87,
                ),
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
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          if (isSearch == null) ...[
            Expanded(
              flex: 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    studentDetailModel.numberOfErrors,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    MistakeViewMistakePage.routeName,
                    arguments: {
                      'studentDetailModel': studentDetailModel,
                      'month': month
                    },
                  );
                  if (onRefresh != null && context.mounted) {
                    await onRefresh!();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    FontAwesomeIcons.eye,
                    size: 18,
                    color: Color(0xFF0288D1),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    MistakeTypeMistakePage.routeName,
                    arguments: studentDetailModel,
                  );
                  if (onRefresh != null && context.mounted) {
                    await onRefresh!();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    FontAwesomeIcons.pen,
                    size: 18,
                    color: Color(0xFF2E7D32),
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
