import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateListClassDialog extends StatefulWidget {
  const CreateListClassDialog({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<CreateListClassDialog> createState() => _CreateListClassDialogState();
}

class _CreateListClassDialogState extends State<CreateListClassDialog> {
  List<Map<String, dynamic>> newDataList = [];
  String? selectedFileName;
  bool isLoading = false;

  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      selectedFileName =
          result.files.single.name; // Save the selected file name

      setState(() {});

      var file = File(filePath);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      Map<String, List<Map<String, dynamic>>> classData = {};

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;

        if (rows.isEmpty) {
          print('No rows found in the table: $table');
          continue;
        }

        // Find the header row
        int headerRowIndex = -1;
        for (int i = 0; i < rows.length; i++) {
          var rowValues = rows[i]
              .map((cell) => cell?.value?.toString().trim() ?? '')
              .toList();
          if (rowValues.contains('Lớp') &&
              rowValues.contains('Giáo Viên Chủ Nhiệm')) {
            headerRowIndex = i;
            break;
          }
        }

        if (headerRowIndex == -1) {
          print('Header row not found');
          continue;
        }

        List<String> headers = rows[headerRowIndex]
            .map((cell) => cell?.value?.toString().trim() ?? '')
            .toList();
        print('Header row: $headers');

        for (int i = headerRowIndex + 1; i < rows.length; i++) {
          var row = rows[i];

          // Print each row for debugging
          print('Row $i: $row');

          if (row.length >= headers.length && row[0] != null) {
            var className = headers.contains('Lớp')
                ? row[headers.indexOf('Lớp')]?.value?.toString() ?? ''
                : '';

            if (className.isNotEmpty) {
              if (!classData.containsKey(className)) {
                classData[className] = []; // Initialize a list for this class
              }

              var newData = {
                'T_name': headers.contains('Giáo Viên Chủ Nhiệm')
                    ? row[headers.indexOf('Giáo Viên Chủ Nhiệm')]
                            ?.value
                            ?.toString() ??
                        ''
                    : '',
                'T_id': headers.contains('Mã Giáo Viên')
                    ? row[headers.indexOf('Mã Giáo Viên')]?.value?.toString() ??
                        ''
                    : '',
                '_className': className,
                '_year': headers.contains('Niên Khóa')
                    ? row[headers.indexOf('Niên Khóa')]?.value?.toString() ?? ''
                    : '',
              };

              classData[className]!.add(newData);
              newDataList.add(newData); // Add data to the class list
            } else {
              print('Class name is empty for row $i');
            }
          } else {
            print('Row $i does not have enough columns or is null');
          }
        }
      }

      // Now classData contains all the students organized by class
      print('Class Data: $classData');
    } else {
      print('Không có file nào được chọn.');
    }
  }

  Future<void> pickExcelFileInWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    Map<String, List<Map<String, dynamic>>> classData = {};

    if (result != null) {
      Uint8List? bytes = result.files.single.bytes;

      if (bytes != null) {
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          var rows = excel.tables[table]!.rows;

          if (rows.isEmpty) {
            print('No rows found in the table: $table');
            continue;
          }

          // Find the header row
          int headerRowIndex = -1;
          for (int i = 0; i < rows.length; i++) {
            var rowValues = rows[i]
                .map((cell) => cell?.value?.toString().trim() ?? '')
                .toList();
            if (rowValues.contains('Lớp') &&
                rowValues.contains('Giáo Viên Chủ Nhiệm')) {
              headerRowIndex = i;
              break;
            }
          }

          if (headerRowIndex == -1) {
            print('Header row not found');
            continue;
          }

          List<String> headers = rows[headerRowIndex]
              .map((cell) => cell?.value?.toString().trim() ?? '')
              .toList();
          print('Header row: $headers');

          for (int i = headerRowIndex + 1; i < rows.length; i++) {
            var row = rows[i];

            // Print each row for debugging
            print('Row $i: $row');

            if (row.length >= headers.length && row[0] != null) {
              var className = headers.contains('Lớp')
                  ? row[headers.indexOf('Lớp')]?.value?.toString() ?? ''
                  : '';

              if (className.isNotEmpty) {
                if (!classData.containsKey(className)) {
                  classData[className] = []; // Initialize a list for this class
                }

                var newData = {
                  'T_name': headers.contains('Giáo Viên Chủ Nhiệm')
                      ? row[headers.indexOf('Giáo Viên Chủ Nhiệm')]
                              ?.value
                              ?.toString() ??
                          ''
                      : '',
                  'T_id': headers.contains('Mã Giáo Viên')
                      ? row[headers.indexOf('Mã Giáo Viên')]
                              ?.value
                              ?.toString() ??
                          ''
                      : '',
                  '_className': className,
                  '_year': headers.contains('Niên Khóa')
                      ? row[headers.indexOf('Niên Khóa')]?.value?.toString() ??
                          ''
                      : '',
                };

                classData[className]!.add(newData);
                newDataList.add(newData);
                print('Added data for class $className: $newData');
              } else {
                print('Class name is empty for row $i');
              }
            } else {
              print('Row $i does not have enough columns or is null');
            }
          }

          setState(() {
            selectedFileName = result.files.single.name; // Lưu tên file đã chọn
          });
        }
      } else {
        print('Không có file nào được chọn.');
      }
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
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.2
            : MediaQuery.of(context).size.width * 0.8,
        child: Wrap(
          children: [
            if (isLoading) Center(child: CircularProgressIndicator()),
            if (!isLoading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'File danh sách lớp',
                        labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: ColorApp.primaryColor),
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
                      controller: TextEditingController(text: selectedFileName),
                      enabled: false,
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonN(
                    label: 'Chọn file',
                    color: Colors.cyanAccent.shade700,
                    colorText: Colors.white,
                    ontap: () {
                      if (kIsWeb) {
                        pickExcelFileInWeb();
                      } else {
                        pickExcelFile();
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (!isLoading) ...[
              Flexible(
                child: ButtonN(
                  ontap: () async {
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
                      return;
                    }

                    setState(() {
                      isLoading = true;
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
                      widget.onCreate();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Thông báo'),
                          content: Text('Đã thêm danh sách lớp thành công.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
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
                        isLoading = false;
                      });
                    }
                  },
                  size: Size(MediaQuery.of(context).size.width * 0.2,
                      MediaQuery.of(context).size.height * 0.05),
                  label: 'Lưu',
                  colorText: Colors.white,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: ButtonN(
                  ontap: () {
                    Navigator.of(context).pop();
                  },
                  size: Size(MediaQuery.of(context).size.width * 0.2,
                      MediaQuery.of(context).size.height * 0.05),
                  label: 'Đóng',
                  colorText: Colors.white,
                  color: Colors.red,
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }
}
