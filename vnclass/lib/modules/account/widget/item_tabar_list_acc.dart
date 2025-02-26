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
  const ItemTabarListAcc({super.key, required this.title, this.typeAcc});
  final String title;
  final String? typeAcc;

  @override
  _ItemTabarListAccState createState() => _ItemTabarListAccState();
}

class _ItemTabarListAccState extends State<ItemTabarListAcc> {
  String fileName = '';
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> teachers = [];

  // [Giữ nguyên toàn bộ logic của bạn từ pickFile đến setFormDataTeacher]
  Future<void> pickFile(String typeAcc) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      setState(() {
        fileName = path.basename(result.files.single.path!);
      });
      print('Đường dẫn file: ${result.files.single.path}');
      if (typeAcc == 'hs') {
        await readExcel(result.files.single.path!);
      } else {
        await readExcelTeacher(result.files.single.path!);
      }
    }
  }

  void countStudentsByClassAndAcademicYear() {
    Map<String, int> countMap = {};
    for (var student in students) {
      String? className = student['class'].toString().toLowerCase();
      String? academicYear = student['academicYear'];
      if (academicYear != null) {
        String key = '$className$academicYear';
        countMap[key] = (countMap[key] ?? 0) + 1;
      }
    }
    countMap.forEach((key, count) {
      print('Cặp $key có $count sinh viên');
    });
    updateClassAmounts(countMap);
  }

  void updateClassAmounts(Map<String, int> countMap) async {
    CollectionReference classCollection =
        FirebaseFirestore.instance.collection('CLASS');
    for (var entry in countMap.entries) {
      String key = entry.key;
      int count = entry.value;
      DocumentReference classDoc = classCollection.doc(key);
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

  Future<void> readExcelTeacher(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excelFile = excel.Excel.decodeBytes(bytes);
    teachers.clear();

    List<String> requiredHeaders = [
      'STT',
      'Mã GV',
      'Họ và tên',
      'Ngày sinh',
      'Giới tính',
      'Email',
      'SĐT',
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
        Map<String, dynamic> teacher = {
          'stt': headers.contains('STT')
              ? row[headers.indexOf('STT')]?.value?.toString()
              : null,
          'idteacher': headers.contains('Mã GV')
              ? row[headers.indexOf('Mã GV')]?.value?.toString()
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
        };
        teachers.add(teacher);
      }
    }
    setState(() {});
    print('Danh sách GV: $teachers');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> setFormData() async {
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
    List<Map<String, dynamic>> accParentsUp = [];
    List<String> init = [];

    studentsUp = students.map((student) {
      String birth = student['birthDate']?.toString() ?? '';
      String ddmm = '';
      if (birth.length >= 10) {
        ddmm = birth.substring(0, 2) + birth.substring(3, 5);
      }
      Random random = Random();
      String xxx = random.nextInt(1000).toString().padLeft(3, '0');
      String id = 'H$ddmm$xxx';
      String gender = student['gender']?.toString() ?? '';
      String phone = student['phone']?.toString() ?? '';
      String email = student['email']?.toString() ?? '';
      String studentName = student['fullName']?.toString() ?? '';
      String parentID = student['phoneParent'].toString() ?? '';
      String classN = student['class']?.toString().toLowerCase() ?? '';
      String academicYear = student['academicYear']?.toString() ?? '';
      String classID = '$classN$academicYear';
      String idstudentdetail = '$id$academicYear';
      studentDetailsUp.add({
        'Class_id': classID,
        'Class_name': classN,
        'ST_id': id,
        '_birthday': birth,
        '_committee': 'Học sinh',
        '_conductAllYear': 'Tốt',
        '_conductTerm1': 'Tốt',
        '_conductTerm2': 'Tốt',
        '_gender': gender,
        '_id': idstudentdetail,
        '_phone': phone,
        '_studentName': studentName,
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

      accParentsUp.add({
        '_accName': 'PHHS $studentName - $id',
        '_birth': '',
        '_email': '',
        '_gender': '',
        '_groupID': 'phuHuynh',
        '_id': parentID,
        '_pass': _hashPassword('123'),
        '_permission': init,
        '_phone': parentID,
        '_status': 'true',
        '_token': init,
        '_userName': parentID,
      });

      conductsUp.add({
        'STDL_id': idstudentdetail,
        '_id': idstudentdetail,
        '_month': monthData,
      });

      parentsUp.add({
        'ACC_id': parentID,
        '_birthday': '',
        '_gender': '',
        '_id': parentID,
        '_parentName': 'PHHS $studentName',
        '_phone': parentID,
      });

      return {
        '_id': id,
        'ACC_id': id,
        'P_id': parentID,
        '_birthday': birth,
        '_gender': gender,
        '_phone': phone,
        '_studentName': studentName,
      };
    }).toList();

    countStudentsByClassAndAcademicYear();
    await Future.wait([
      Future.wait(studentsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('STUDENT')
            .doc(docId)
            .set(studentup);
      })),
      Future.wait(studentDetailsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('STUDENT_DETAIL')
            .doc(docId)
            .set(studentup);
      })),
      Future.wait(conductsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('CONDUCT_MONTH')
            .doc(docId)
            .set(studentup);
      })),
      Future.wait(accountsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('ACCOUNT')
            .doc(docId)
            .set(studentup);
      })),
      Future.wait(accParentsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('ACCOUNT')
            .doc(docId)
            .set(studentup);
      })),
      Future.wait(parentsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('PARENT')
            .doc(docId)
            .set(studentup);
      })),
    ]);
  }

  Map<String, dynamic>? getTeacherIfUnique(String teacherId) {
    final foundTeachers =
        teachers.where((teacher) => teacher['idteacher'] == teacherId).toList();
    if (foundTeachers.length == 1) {
      return foundTeachers.first;
    }
    return null;
  }

  Future<void> setFormDataTeacher() async {
    print('Dữ liệu giáo viên trước khi tải lên: ${teachers.length}');
    List<Map<String, dynamic>> teachersUp = [];
    List<Map<String, dynamic>> accountsUp = [];
    List<String> init = [];

    teachersUp = teachers.map((teacher) {
      String birth = teacher['birthDate']?.toString() ?? '';
      String gender = teacher['gender']?.toString() ?? '';
      String id = teacher['idteacher']?.toString() ?? '';
      String phone = teacher['phone']?.toString() ?? '';
      String email = teacher['email']?.toString() ?? '';
      String teacherName = teacher['fullName']?.toString() ?? '';

      accountsUp.add({
        '_accName': teacherName,
        '_birth': birth,
        '_email': email,
        '_gender': gender,
        '_groupID': 'giaoVien',
        '_id': id,
        '_pass': _hashPassword('123'),
        '_permission': init,
        '_phone': phone,
        '_status': 'true',
        '_token': init,
        '_userName': id,
      });

      return {
        '_id': id,
        'ACC_id': id,
        '_birthday': birth,
        '_gender': gender,
        '_phone': phone,
        '_teacherName': teacherName,
      };
    }).toList();

    await Future.wait([
      Future.wait(teachersUp.map((teacher) {
        String docId = teacher['_id'];
        return FirebaseFirestore.instance
            .collection('TEACHER')
            .doc(docId)
            .set(teacher);
      })),
      Future.wait(accountsUp.map((studentup) {
        String docId = studentup['_id'];
        return FirebaseFirestore.instance
            .collection('ACCOUNT')
            .doc(docId)
            .set(studentup);
      })),
    ]);
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
        const SnackBar(content: Text('Tải lên thành công!')),
      );
    } catch (e) {
      print('Lỗi khi tải lên: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            // Khu vực chọn file
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade400, // Viền rõ hơn với màu xám nhạt
                  width: 1.5, // Độ dày viền tăng lên để rõ hơn
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      fileName.isNotEmpty ? fileName : 'Chưa chọn file',
                      style: TextStyle(
                        fontSize: 16,
                        color: fileName.isNotEmpty
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: () {
                        pickFile(widget.typeAcc ?? '');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Chọn file',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Nút điều khiển
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: fileName.isNotEmpty
                        ? () {
                            if (widget.typeAcc == 'bgh' ||
                                widget.typeAcc == 'gv') {
                              setFormDataTeacher();
                            } else {
                              setFormData();
                            }
                          }
                        : null, // Vô hiệu hóa nếu chưa chọn file
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Tải lên',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Thoát',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Hiển thị số lượng dữ liệu (tùy chọn)
            if (fileName.isNotEmpty &&
                (students.isNotEmpty || teachers.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Số lượng: ${widget.typeAcc == 'hs' ? students.length : teachers.length} bản ghi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
