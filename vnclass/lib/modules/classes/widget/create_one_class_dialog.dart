import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateOneClassDialog extends StatefulWidget {
  const CreateOneClassDialog({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<CreateOneClassDialog> createState() => _CreateOneClassDialogState();
}

class _CreateOneClassDialogState extends State<CreateOneClassDialog> {
  String className = '';
  String teacherId = '';
  String teacherName = '';
  String year = '';

  String? classNameError;
  String? teacherIdError;
  String? teacherNameError;
  String? yearError;

  void _validateInputs() {
    setState(() {
      classNameError = className.isEmpty ? 'Vui lòng nhập lớp học' : null;
      teacherIdError = teacherId.isEmpty ? 'Vui lòng nhập mã GVCN' : null;
      teacherNameError = teacherName.isEmpty ? 'Vui lòng nhập tên GVCN' : null;
      yearError = year.isEmpty ? 'Vui lòng nhập niên khóa' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Thêm lớp học:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: SizedBox(
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.2
            : MediaQuery.of(context).size.width * 0.8,
        child: Wrap(
          runSpacing: MediaQuery.of(context).size.width * 0.01,
          children: [
            TextfieldWidget(
              labelText: 'Lớp học',
              colorBorder: Color(0xFF666666),
              onChanged: (value) {
                className = value;
                classNameError = null; // Xóa lỗi khi người dùng nhập
              },
              errorText: classNameError,
              onTap: () {
                setState(() {
                  classNameError = null; // Ẩn thông báo lỗi
                });
              },
            ),
            TextfieldWidget(
              labelText: 'Mã GVCN',
              colorBorder: Color(0xFF666666),
              onChanged: (value) {
                teacherId = value;
                teacherIdError = null; // Xóa lỗi khi người dùng nhập
              },
              errorText: teacherIdError,
              onTap: () {
                setState(
                  () {
                    teacherIdError = null; // Ẩn thông báo lỗi
                  },
                );
              },
            ),
            TextfieldWidget(
              labelText: 'Tên GVCN',
              colorBorder: Color(0xFF666666),
              onChanged: (value) {
                teacherName = value;
                teacherNameError = null; // Xóa lỗi khi người dùng nhập
              },
              errorText: teacherNameError,
              onTap: () {
                setState(() {
                  teacherNameError = null; // Ẩn thông báo lỗi
                });
              },
            ),
            TextfieldWidget(
              labelText: 'Niên khóa',
              colorBorder: Color(0xFF666666),
              onChanged: (value) {
                year = value;
                yearError = null; // Xóa lỗi khi người dùng nhập
              },
              errorText: yearError,
              onTap: () {
                setState(() {
                  yearError = null; // Ẩn thông báo lỗi
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        ButtonN(
          ontap: () async {
            _validateInputs(); // Kiểm tra các trường

            if (classNameError != null ||
                teacherIdError != null ||
                teacherNameError != null ||
                yearError != null) {
              return; // Dừng lại nếu có lỗi
            }

            try {
              if (await ClassController.classExists(
                  className.toLowerCase().replaceAll(' ', '') +
                      year.replaceAll(' ', ''))) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Lớp học đã tồn tại.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                await ClassController.createClass(
                    context, className, teacherId, teacherName, year);
                widget.onCreate();

                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Thông báo'),
                      content: Text('Tạo lớp học thành công!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            } catch (e) {
              Navigator.of(context).pop(); // Đóng dialog xóa
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Lỗi'),
                    content: Text('Tạo lớp học thất bại!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
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
            kIsWeb
                ? MediaQuery.of(context).size.width * 0.05
                : MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Thêm',
          textSize: 13,
          color: Colors.blue,
          colorText: Colors.white,
        ),
        ButtonN(
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            kIsWeb
                ? MediaQuery.of(context).size.width * 0.05
                : MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          textSize: 13,
          label: 'Đóng',
          color: Colors.red,
          colorText: Colors.white,
        ),
      ],
    );
  }
}
