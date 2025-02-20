import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';

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
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextfieldWidget(
                        labelText: classModel.className.toString(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextfieldWidget(
                        labelText: teacherId.isEmpty ? 'Mã GVCN' : teacherId,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: DropMenuWidget(
                        items: teacherList
                                ?.map((teacher) => teacher['name'])
                                .toList() ??
                            [],
                        selectedItem: selectedTeacher,
                        onChanged: (value) {
                          final selected = teacherList?.firstWhere(
                              (teacher) => teacher['name'] == value);
                          if (selected != null) {
                            selectedTeacher = value;
                            teacherId =
                                selected['id']!; // Cập nhật mã giáo viên
                          }
                          setState(() {}); // Cập nhật lại giao diện
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextfieldWidget(
                        labelText: classModel.year.toString(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: [
        ButtonN(
          ontap: () async {
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
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Sửa',
          color: Colors.blue,
        ),
        ButtonN(
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Đóng',
          color: Colors.red,
        ),
      ],
    );
  }
}
