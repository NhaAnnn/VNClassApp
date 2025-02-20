import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';

class CreateListClassDialog extends StatefulWidget {
  const CreateListClassDialog({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<CreateListClassDialog> createState() => _CreateListClassDialogState();
}

class _CreateListClassDialogState extends State<CreateListClassDialog> {
  List<Map<String, dynamic>> newDataList = []; // Danh sách để lưu nhiều lớp học
  String? selectedFileName; // Biến lưu tên file đã chọn
  bool isLoading = false; // Trạng thái tải

  Future<void> pickExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      selectedFileName = result.files.single.name; // Lưu tên file đã chọn

      setState(() {});

      var file = File(filePath);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;

        // Bỏ qua dòng đầu tiên (tiêu đề)
        for (int i = 2; i < rows.length; i++) {
          var row = rows[i];
          if (row.isNotEmpty) {
            var newData = {
              'T_name': row[2]?.value.toString(),
              'T_id': row[1]?.value.toString(),
              '_className': row[0]?.value.toString(),
              '_year': row[3]?.value.toString(),
            };
            newDataList.add(newData); // Thêm dữ liệu vào danh sách
          }
        }
      }
    } else {
      print('Không có file nào được chọn.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        isLoading ? '' : 'Thêm Danh sách lớp học:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) // Hiển thị vòng tròn tải nếu đang tải
                Center(child: CircularProgressIndicator()),
              if (!isLoading) ...[
                // Chỉ hiển thị khi không đang tải
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'File danh sách lớp',
                            labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: ColorApp.primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 29, 92, 252),
                                  width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorApp.primaryColor, width: 2.0),
                            ),
                          ),
                          controller: TextEditingController(
                              text: selectedFileName), // Hiển thị tên file
                          enabled: false, // Không cho phép chỉnh sửa
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Expanded(
                      flex: 3,
                      child: ButtonN(
                        label: 'Chọn file',
                        color: Colors.cyanAccent.shade700,
                        colorText: Colors.white,
                        ontap: () {
                          pickExcelFile(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isLoading) ...[
              ButtonN(
                ontap: () async {
                  // Kiểm tra xem file đã được chọn chưa
                  if (selectedFileName == null || selectedFileName!.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Thông báo'),
                        content: Text('Vui lòng chọn file trước khi lưu.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return; // Dừng lại nếu không có file
                  }

                  setState(() {
                    isLoading = true; // Bắt đầu quá trình tải
                  });

                  try {
                    for (var newData in newDataList) {
                      await ClassController.createClass(
                        context,
                        newData['_className'],
                        newData['T_name'],
                        newData['T_id'],
                        newData['_year'],
                      );
                    }

                    // Hiển thị thông báo thành công
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Thông báo'),
                        content: Text('Đã thêm danh sách lớp thành công.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Đóng thông báo
                              Navigator.of(context).pop(); // Đóng dialog chính
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );

                    // Tự động đóng dialog sau 2 giây
                    // await Future.delayed(Duration(seconds: 0));
                  } catch (e) {
                    print(e);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Lỗi'),
                        content: Text('Thêm danh sách lớp thất bại: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } finally {
                    setState(() {
                      isLoading = false; // Kết thúc quá trình tải
                    });
                  }
                },
                size: Size(
                  MediaQuery.of(context).size.width * 0.2,
                  MediaQuery.of(context).size.height * 0.05,
                ),
                label: 'Lưu',
                colorText: Colors.white,
                color: Colors.blueAccent,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              ButtonN(
                ontap: () {
                  Navigator.of(context).pop();
                },
                size: Size(
                  MediaQuery.of(context).size.width * 0.2,
                  MediaQuery.of(context).size.height * 0.05,
                ),
                label: 'Đóng',
                colorText: Colors.white,
                color: Colors.red,
              ),
            ]
          ],
        ),
      ],
    );
  }
}
