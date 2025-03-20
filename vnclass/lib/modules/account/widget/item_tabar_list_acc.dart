import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel;
import 'package:vnclass/common/widget/button_widget.dart';

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

  Future<void> downloadTemplate(String typeAcc) async {
    String? assetPath;
    String fileName;

    switch (typeAcc) {
      case 'bgh':
        assetPath = 'assets/files/BGH_template.xlsx';
        fileName = 'BGH_template.xlsx';
        break;
      case 'gv':
        assetPath = 'assets/files/GiaoVien_template.xlsx';
        fileName = 'GiaoVien_template.xlsx';
        break;
      case 'hs':
        assetPath = 'assets/files/HocSinh_template.xlsx';
        fileName = 'HocSinh_template.xlsx';
        break;
      default:
        return;
    }

    try {
      // Đọc dữ liệu từ assets
      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer;
      final bytes =
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      // Lấy thư mục Downloads
      final directory = Directory('/storage/emulated/0/Download');
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Ghi file vào thư mục Downloads
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tải mẫu về: $filePath'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Lỗi khi tải mẫu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tải mẫu thất bại!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
      'Mã HS',
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
          'idstudent': headers.contains('Mã HS')
              ? row[headers.indexOf('Mã HS')]?.value?.toString()
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
      String id = student['idstudent']?.toString() ?? '';
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
        '_accName': 'PHHS - $studentName - $id',
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
        '_parentName': 'PHHS - $studentName - $id',
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

  Future<void> setFormDataTeacher(String posi) async {
    print('Dữ liệu giáo viên trước khi tải lên: ${teachers.length}');
    print('type $posi');
    String position = '';
    if (posi == 'gv') {
      position = 'giaoVien';
    } else if (posi == 'bgh') {
      position = 'banGH';
    }
    print('position $position');
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
        '_groupID': position,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Xác định tên file mẫu dựa trên typeAcc
    String templateName;
    switch (widget.typeAcc) {
      case 'bgh':
        templateName = 'BGH_template.xlsx';
        break;
      case 'gv':
        templateName = 'GiaoVien_template.xlsx';
        break;
      case 'hs':
        templateName = 'HocSinh_template.xlsx';
        break;
      default:
        templateName = 'Unknown_template.xlsx';
    }

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
            const SizedBox(height: 8),
            // Tên file mẫu và nút tải mẫu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Mẫu: $templateName',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.visible, // Cho phép xuống dòng
                  ),
                ),
                ElevatedButton(
                  onPressed: () => downloadTemplate(widget.typeAcc ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Tải mẫu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Khu vực chọn file (giữ nguyên)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.5,
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
            // Nút điều khiển (giữ nguyên)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: fileName.isNotEmpty
                        ? () {
                            if (widget.typeAcc == 'bgh' ||
                                widget.typeAcc == 'gv') {
                              setFormDataTeacher(widget.typeAcc ?? '');
                            } else {
                              setFormData();
                            }
                          }
                        : null,
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
            // Số lượng dữ liệu (giữ nguyên)
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
