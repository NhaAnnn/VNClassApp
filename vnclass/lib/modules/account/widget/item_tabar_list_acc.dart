import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:excel/excel.dart' as excel;
import 'dart:io';

class ItemTabarListAcc extends StatefulWidget {
  const ItemTabarListAcc({
    super.key,
    required this.title,
  });
  final String title;

  @override
  _ItemTabarListAccState createState() => _ItemTabarListAccState();
}

class _ItemTabarListAccState extends State<ItemTabarListAcc> {
  String fileName = '';
  List<Map<String, dynamic>> students = [];

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      setState(() {
        fileName = path.basename(result.files.single.path!);
      });
      print('Đường dẫn file: ${result.files.single.path}');
      await readExcel(result.files.single.path!);
    }
  }

  void countStudentsByClassAndAcademicYear() {
    // Tạo một Map để lưu trữ số lượng sinh viên theo cặp class + academicYear
    Map<String, int> countMap = {};

    for (var student in students) {
      String? className = student['class'].toString().toLowerCase();
      String? academicYear = student['academicYear'];

      // Kiểm tra nếu cả class và academicYear đều không null
      if (academicYear != null) {
        // Tạo key cho cặp class + academicYear
        String key = '$className$academicYear';

        // Tăng số lượng cho cặp này
        countMap[key] = (countMap[key] ?? 0) + 1;
      }
    }

    // In ra số lượng sinh viên theo từng cặp class + academicYear
    countMap.forEach((key, count) {
      print('Cặp $key có $count sinh viên');
    });
  }

  void updateClassAmounts(Map<String, int> countMap) async {
    // Lấy reference tới collection CLASS
    CollectionReference classCollection =
        FirebaseFirestore.instance.collection('CLASS');

    // Lặp qua từng cặp key-value trong countMap
    for (var entry in countMap.entries) {
      String key = entry.key;
      int count = entry.value;

      // Tìm document có id tương ứng với key
      DocumentReference classDoc = classCollection.doc(key);

      // Cập nhật trường _amount
      await classDoc.update({'_amount': count}).catchError((error) {
        print('Error updating document $key: $error');
      });
    }
  }

  Future<void> readExcel(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excelFile = excel.Excel.decodeBytes(bytes);
    students.clear();

    List<String> requiredHeaders = [
      'STT',
      'Lớp',
      'Niên Khóa',
      'Họ và tên',
      'Ngày sinh',
      'Giới tính',
      'Email',
      'SĐT',
      'SĐT PHHS'
    ];

    for (var table in excelFile.tables.keys) {
      var rows = excelFile.tables[table]!.rows;
      if (rows.isEmpty) continue;

      int headerRowIndex = -1;
      for (int i = 0; i < rows.length; i++) {
        var rowValues = rows[i]
            .map((cell) => cell?.value?.toString().trim() ?? '')
            .toList();
        bool isHeader =
            requiredHeaders.every((header) => rowValues.contains(header));
        if (isHeader) {
          headerRowIndex = i;
          break;
        }
      }

      if (headerRowIndex == -1) {
        print("Không tìm thấy dòng header trong sheet: $table");
        continue;
      }

      List<String> headers = rows[headerRowIndex]
          .map((cell) => cell?.value?.toString().trim() ?? '')
          .toList();
      print('Header row: $headers');

      for (int i = headerRowIndex + 1; i < rows.length; i++) {
        var row = rows[i];
        if (row.isEmpty ||
            row.every((cell) =>
                cell?.value == null || cell?.value.toString().trim() == '')) {
          continue;
        }
        List<String> persionList = [];
        Map<String, dynamic> student = {
          'stt': headers.contains('STT')
              ? row[headers.indexOf('STT')]?.value?.toString()
              : null,
          'class': headers.contains('Lớp')
              ? row[headers.indexOf('Lớp')]?.value?.toString()
              : null,
          'academicYear': headers.contains('Niên Khóa')
              ? row[headers.indexOf('Niên Khóa')]?.value?.toString()
              : null,
          'fullName': headers.contains('Họ và tên')
              ? row[headers.indexOf('Họ và tên')]?.value?.toString()
              : null,
          'birthDate': headers.contains('Ngày sinh')
              ? row[headers.indexOf('Ngày sinh')]?.value?.toString()
              : null,
          'gender': headers.contains('Giới tính')
              ? row[headers.indexOf('Giới tính')]?.value?.toString()
              : null,
          'email': headers.contains('Email')
              ? row[headers.indexOf('Email')]?.value?.toString()
              : null,
          'phone': headers.contains('SĐT')
              ? row[headers.indexOf('SĐT')]?.value?.toString()
              : null,
          'phoneParent': headers.contains('SĐT PHHS')
              ? row[headers.indexOf('SĐT PHHS')]?.value?.toString()
              : null,
          'persion': persionList,
        };
        students.add(student);
      }
    }

    setState(() {});
    print('Danh sách sinh viên: $students');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> setFormData() async {
    // Flatten monthData into a simple map
    Map<String, Set<String>> monthData = {
      'month1': {'100', 'Tốt'},
      'month2': {'100', 'Tốt'},
      'month3': {'100', 'Tốt'},
      'month4': {'100', 'Tốt'},
      'month5': {'100', 'Tốt'},
      'month6': {'100', 'Tốt'},
      'month7': {'100', 'Tốt'},
      'month8': {'100', 'Tốt'},
      'month9': {'100', 'Tốt'},
      'month10': {'100', 'Tốt'},
      'month11': {'100', 'Tốt'},
      'month12': {'100', 'Tốt'},
    };
    print('Dữ liệu sinh viên trước khi tải lên: ${students.length}');

    List<Map<String, dynamic>> studentDetailsUp = [];
    List<Map<String, dynamic>> studentsUp = [];
    List<Map<String, dynamic>> accountsUp = [];
    List<Map<String, dynamic>> conductsUp = [];
    List<Map<String, dynamic>> parentsUp = [];

    List<String> init = [];

    // Tạo danh sách studentsUp
    studentsUp = students.map((student) {
      // Chuyển birthDate về String và kiểm tra độ dài
      String birth = student['birthDate']?.toString() ?? '';
      String ddmm = '';

      if (birth.length >= 10) {
        // Lấy 2 ký tự đầu cho ngày và tháng
        ddmm = birth.substring(0, 2) + birth.substring(3, 5); // Lấy dd và mm
      }

      // Tạo 3 chữ số ngẫu nhiên
      Random random = Random();
      String xxx = random
          .nextInt(1000)
          .toString()
          .padLeft(3, '0'); // Đảm bảo là 3 chữ số

      // Kết hợp để tạo ID
      String id = 'H$ddmm$xxx';
      // Các trường khác
      String gender = student['gender']?.toString() ?? '';
      String phone = student['phone']?.toString() ?? '';
      String email = student['email']?.toString() ?? '';
      String studentName = student['fullName']?.toString() ?? '';
      String parentID = student['phoneParent'].toString() ?? '';
      // Tạo đối tượng cho studentDetailsUp
      String classN = student['class']?.toString().toLowerCase() ?? '';
      String academicYear = student['academicYear']?.toString() ?? '';
      String classID = '$classN$academicYear';
      String idstudentdetail = '$id$academicYear';
      studentDetailsUp.add({
        'Class_id': classID,
        'Class_name': classN,
        'ST_id': id, // Gán ST_id bằng id
        '_birthday': birth,
        '_committee': 'Học sinh',
        '_conductAllYear': 'Tốt',
        '_conductTerm1': 'Tốt',
        '_conductTerm2': 'Tốt',
        '_gender': gender,
        '_id': idstudentdetail,
        '_phone': phone,
        '_studentName': studentName,
        // Bạn có thể thêm các trường khác nếu cần
      });

      accountsUp.add({
        '_accName': studentName,
        '_birth': birth,
        '_email': email,
        '_gender': gender,
        '_groupID': 'hocSinh',
        '_id': id,
        '_pass': _hashPassword('123'),
        '_permission': init,
        '_phone': phone,
        '_status': 'true',
        '_token': init,
        '_userName': id,
      });

      conductsUp.add({
        'STDL_id': idstudentdetail,
        '_id': idstudentdetail,
        '_month': monthData,
      });

      return {
        '_id': id,
        'ACC_id': id,
        'P_id': parentID,
        '_birthday': birth,
        '_gender': gender,
        '_phone': phone,
        '_studentName': studentName,
        // Bạn có thể thêm các trường khác nếu cần
      };
    }).toList();

    // print('Dữ liệu studentUp: $studentsUp');
    // print('Dữ liệu studentDetailsUp: $studentDetailsUp');
    // print('Dữ liệu conductsUp: $conductsUp');
    // print('Dữ liệu accountsUp: $accountsUp');
    countStudentsByClassAndAcademicYear();
    // await Future.wait([
    //   Future.wait(studentsUp.map((studentup) {
    //     String docId = studentup['_id'];
    //     return FirebaseFirestore.instance
    //         .collection('STUDENT')
    //         .doc(docId)
    //         .set(studentup);
    //   })),
    // ]);
  }

  Future<void> uploadData() async {
    print('Dữ liệu sinh viên trước khi tải lên: $students');
    try {
      for (var student in students) {
        await FirebaseFirestore.instance.collection('STUDENT').add(student);
      }

      setState(() {
        students.clear();
        fileName = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải lên thành công!')),
      );
    } catch (e) {
      print('Lỗi khi tải lên: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(widget.title),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    spreadRadius: 4,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(
                        fileName.isNotEmpty ? fileName : 'Chưa chọn file',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: ButtonWidget(
                        title: 'Chọn file',
                        ontap: pickFile,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Row(
              children: [
                ButtonWidget(
                  title: 'Tải lên',
                  ontap: () {
                    setFormData();
                    // uploadData();
                  },
                ),
                ButtonWidget(
                  title: 'Thoát',
                  color: Colors.red,
                  ontap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
