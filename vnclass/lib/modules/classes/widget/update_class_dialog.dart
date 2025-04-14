import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UpdateClassDialog extends StatefulWidget {
  const UpdateClassDialog({
    super.key,
    required this.classModel,
    required this.onUpdate,
  });

  final ClassModel classModel;
  final VoidCallback onUpdate;

  @override
  State<UpdateClassDialog> createState() => _UpdateClassDialogState();
}

class _UpdateClassDialogState extends State<UpdateClassDialog> {
  List<Map<String, String>>? teacherList; // Danh sách giáo viên
  String? selectedTeacher;
  String teacherId = ''; // Mã giáo viên

  ClassModel get classModel => widget.classModel;

  Future<void> getTeachers() async {
    List<Map<String, String>> teachers = [];

    try {
      // Lấy dữ liệu từ collection TEACHER
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('TEACHER').get();

      // Lặp qua từng document và lấy tên và ID giáo viên
      for (var doc in querySnapshot.docs) {
        teachers.add({
          'id': doc['_id'], // Giả sử trường ID là 'T_id'
          'name': doc['_teacherName'], // Giả sử trường tên là '_teacherName'
        });
      }
      setState(() {
        teacherList = teachers; // Cập nhật danh sách giáo viên
      });
    } catch (e) {
      print("Lỗi khi lấy danh sách giáo viên: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Chỉnh sửa lớp học:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: SizedBox(
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.2
            : MediaQuery.of(context).size.width * 0.8,
        child: Wrap(
          runSpacing: MediaQuery.of(context).size.width * 0.01,
          children: [
            TextfieldWidget(
              labelText: classModel.className.toString(),
              colorBorder: Color(0xFF666666),
            ),
            TextfieldWidget(
              labelText: teacherId.isEmpty ? 'Mã GVCN' : teacherId,
              colorBorder: Color(0xFF666666),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.065,
              child: DropMenuWidget(
                items:
                    teacherList?.map((teacher) => teacher['name']).toList() ??
                        [],
                selectedItem: selectedTeacher,
                onChanged: (value) {
                  final selected = teacherList
                      ?.firstWhere((teacher) => teacher['name'] == value);
                  if (selected != null) {
                    selectedTeacher = value;
                    teacherId = selected['id']!; // Cập nhật mã giáo viên
                  }
                  setState(() {}); // Cập nhật lại giao diện
                },
              ),
            ),
            TextfieldWidget(
              labelText: classModel.year.toString(),
              colorBorder: Color(0xFF666666),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            try {
              await ClassController.updateTeacherName(
                  classModel.id!, teacherId, selectedTeacher!);
              widget.onUpdate();

              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Cập nhật thành công!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog thông báo
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } catch (e) {
              Navigator.of(context).pop(); // Đóng dialog xóa
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Lỗi'),
                    content: Text('Cập nhật thất bại!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog thông báo
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            fixedSize: Size(
              kIsWeb
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.2,
              MediaQuery.of(context).size.height * 0.05,
            ),
          ),
          child: const Text(
            'Sửa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            fixedSize: Size(
              kIsWeb
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.2,
              MediaQuery.of(context).size.height * 0.05,
            ),
          ),
          child: const Text(
            'Đóng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
