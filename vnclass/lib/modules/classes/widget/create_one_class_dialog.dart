import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';

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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Thêm lớp học:',
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
                      child: TextfieldWidget(
                        labelText: 'Lớp học:',
                        onChanged: (value) {
                          className = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: TextfieldWidget(
                        labelText: 'Mã GVCN',
                        onChanged: (value) {
                          teacherId = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: TextfieldWidget(
                        labelText: 'Tên GVCN',
                        onChanged: (value) {
                          teacherName = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: TextfieldWidget(
                        labelText: 'Niên khóa',
                        onChanged: (value) {
                          year = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ]),
        ),
      ),
      actions: [
        ButtonN(
          ontap: () async {
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
                // Bỏ qua lớp này
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
                            Navigator.of(context)
                                .pop(); // Đóng dialog thông báo
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            } catch (e) {
              // Hiện thông báo thất bại
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
          label: 'Thêm',
          color: Colors.blue,
          colorText: Colors.white,
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
          colorText: Colors.white,
        ),
      ],
    );
  }
}
