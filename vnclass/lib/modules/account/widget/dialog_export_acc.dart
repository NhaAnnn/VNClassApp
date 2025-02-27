import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';

class DialogExportAcc extends StatefulWidget {
  const DialogExportAcc({super.key});

  @override
  State<DialogExportAcc> createState() => _DialogExportAccState();
}

class _DialogExportAccState extends State<DialogExportAcc> {
  String? selectedOption;
  bool isExporting = false;
  String? selectedYear;
  String? selectedClass;
  List<String> years = ['2023-2024', '2024-2025']; // Ví dụ
  List<String> classes = ['10A1', '10A2', '11B1', '10a6', 'Tất cả']; // Ví dụ
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 6,
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Text(
          'Xuất Báo Cáo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
      ),
      contentPadding:
          const EdgeInsets.all(8), // Giảm padding mặc định của content
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccountSelectionCard(),
            if (selectedOption == 'Học sinh - PHHS') ...[
              const SizedBox(height: 10),
              _buildClassSelectionCard(),
            ],
            const SizedBox(height: 10),
            _buildExportActionCard(),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildDownloadButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildCancelButton()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelectionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn loại tài khoản',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 6),
            Column(
              children: [
                for (var option in const [
                  'Học sinh - PHHS',
                  'Giáo viên',
                  'Ban giám hiệu'
                ])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                            selectedYear = null;
                            selectedClass = null;
                          });
                        },
                      ),
                      Text(
                        option,
                        style:
                            const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelectionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            DropMenuWidget(
              items: years,
              hintText: 'Chọn năm học',
              selectedItem: selectedYear,
              onChanged: (newValue) => setState(() => selectedYear = newValue!),
            ),
            const SizedBox(height: 8),
            DropMenuWidget(
              items: classes,
              hintText: 'Chọn lớp',
              selectedItem: selectedClass,
              onChanged: (newValue) =>
                  setState(() => selectedClass = newValue!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportActionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Dữ liệu xuất: ${selectedOption == 'Học sinh - PHHS' ? 'Báo cáo thông tin học sinh' : 'Báo cáo thông tin nhân sự'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isExporting
                  ? null
                  : () async {
                      setState(() => isExporting = true);
                      await exportToExcel(context);
                      setState(() => isExporting = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Xuất file',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return ElevatedButton.icon(
      onPressed: isExporting
          ? null
          : () async {
              setState(() => isExporting = true);
              await exportToExcel(context);
              setState(() => isExporting = false);
            },
      icon: const Icon(Icons.download, color: Colors.white, size: 18),
      label: const Text(
        'Tải xuống',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton.icon(
      onPressed: isExporting ? null : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close, color: Colors.white, size: 18),
      label: const Text(
        'Thoát',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  String getColumnLetter(int colIndex) {
    return String.fromCharCode(65 + colIndex);
  }

  Future<void> exportToExcel(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        await _handleAndroid13Permissions(context);
      } else {
        await _handleLegacyAndroidPermissions(context);
      }
    }

    var excelFile = excel.Excel.createExcel();
    await _createSheetsByClassId(excelFile);
  }

  Future<void> _handleAndroid13Permissions(BuildContext context) async {
    final status = await Permission.photos.status;
    if (!status.isGranted) {
      final result = await Permission.photos.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền để lưu file')),
        );
        if (result.isPermanentlyDenied) await openAppSettings();
      }
    }
  }

  Future<void> _handleLegacyAndroidPermissions(BuildContext context) async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền để lưu file')),
        );
        if (result.isPermanentlyDenied) await openAppSettings();
      }
    }
  }

  Future<List<Map<String, dynamic>>> _batchQuery(
      String collection, String field, List<String> ids,
      {String? whereClause, String? whereValue}) async {
    const batchSize = 10;
    List<QuerySnapshot<Map<String, dynamic>>> batches = [];

    for (int i = 0; i < ids.length; i += batchSize) {
      final batchIds = ids.sublist(
          i, i + batchSize > ids.length ? ids.length : i + batchSize);
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(collection)
          .where(field, whereIn: batchIds);
      if (whereClause != null && whereValue != null) {
        query = query.where(whereClause, isEqualTo: whereValue);
      }
      final snapshot = await query.get();
      batches.add(snapshot);
    }

    return batches
        .expand((batch) => batch.docs)
        .map((doc) => doc.data())
        .toList();
  }

  Future<void> _createSheetsByClassId(excel.Excel excelFile) async {
    // Lấy dữ liệu tài khoản dựa vào selectedOption
    final accountSnapshot = await FirebaseFirestore.instance
        .collection('ACCOUNT')
        .where('_groupID',
            isEqualTo: selectedOption == 'Học sinh - PHHS'
                ? 'hocSinh'
                : selectedOption == 'Giáo viên'
                    ? 'giaoVien'
                    : 'banGH')
        .get();

    if (accountSnapshot.docs.isEmpty) return;

    final accountMap = {
      for (var doc in accountSnapshot.docs) doc['_id'] as String: doc.data()
    };
    final accIds = accountMap.keys.toList();

    if (selectedOption == 'Học sinh - PHHS') {
      // Logic cho học sinh
      final studentDocs = await _batchQuery('STUDENT', 'ACC_id', accIds);
      final studentMap = {
        for (var doc in studentDocs) doc['_id'] as String: doc
      };
      final stIds = studentMap.keys.toList();

      final studentDetailDocs =
          await _batchQuery('STUDENT_DETAIL', 'ST_id', stIds);
      final studentDetailMap = {
        for (var doc in studentDetailDocs) doc['ST_id'] as String: doc
      };

      // Lọc lớp theo năm học và lớp được chọn
      Query<Map<String, dynamic>> classQuery =
          FirebaseFirestore.instance.collection('CLASS');

      if (selectedYear != null && selectedClass == null) {
        // Chỉ chọn năm học
        classQuery = classQuery.where('_year', isEqualTo: selectedYear);
      } else if (selectedYear != null &&
          selectedClass != null &&
          selectedClass != 'Tất cả') {
        // Chọn cả năm và lớp cụ thể
        classQuery = classQuery.where('_id',
            isEqualTo:
                '${selectedClass.toString().toLowerCase()}${selectedYear.toString()}');
      } else if (selectedYear != null && selectedClass == 'Tất cả') {
        // Chọn năm và tất cả lớp
        classQuery = classQuery.where('_year', isEqualTo: selectedYear);
      }

      final classDocs = await classQuery.get();
      final classMap = {
        for (var doc in classDocs.docs)
          doc.id: ClassMistakeModel.fromFirestore(doc)
      };
      final classIds = classMap.keys.toList();

      if (classIds.isEmpty) return;

      // Xử lý song song dữ liệu cho từng lớp
      final futures = classIds.map((classId) async {
        return _fetchStudentDataOptimized(
            classId, accountMap, studentMap, studentDetailMap);
      }).toList();

      final results = await Future.wait(futures);

      // Tạo một file Excel duy nhất với nhiều sheet (mỗi lớp một sheet)
      final defaultSheetName = excelFile.getDefaultSheet()!;
      for (int i = 0; i < classIds.length; i++) {
        final classId = classIds[i];
        final sheetName = classId;

        // Nếu là sheet đầu tiên, sử dụng sheet mặc định và đổi tên
        if (i == 0) {
          excelFile.rename(defaultSheetName, sheetName);
          final sheet = excelFile[sheetName];
          _fillClassInfo(sheet, classId, classMap[classId]);
          await _fillStudentExcelTable(sheet, results[i], excelFile);
        } else {
          // Thêm sheet mới cho các lớp còn lại
          final sheet = excelFile[sheetName];
          _fillClassInfo(sheet, classId, classMap[classId]);
          await _fillStudentExcelTable(sheet, results[i], excelFile);
        }
      }

      // Lưu file duy nhất sau khi xử lý tất cả sheet
      try {
        final directory = Directory('/storage/emulated/0/Download');
        final path =
            '${directory.path}/st_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(path);
        await file.writeAsBytes(excelFile.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File đã được lưu tại: $path')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xuất file: ${e.toString()}')),
        );
      }
    } else {
      // Logic cho Giáo viên/Ban giám hiệu (giữ nguyên không thay đổi)
      final accountSnapshot = await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .where('_groupID',
              isEqualTo: selectedOption == 'Giáo viên' ? 'giaoVien' : 'banGH')
          .get();

      if (accountSnapshot.docs.isEmpty) return;

      final accountMap = {
        for (var doc in accountSnapshot.docs) doc['_id'] as String: doc.data()
      };
      final accIds = accountMap.keys.toList();

      final teacherDocs = await _batchQuery(
          selectedOption == 'Giáo viên' ? 'TEACHER' : 'TEACHER',
          'ACC_id',
          accIds);
      final teacherMap = {
        for (var doc in teacherDocs) doc['_id'] as String: doc
      };

      // Tạo một sheet duy nhất
      final sheet = excelFile[excelFile.getDefaultSheet()!];
      _fillStaffInfo(sheet);
      await _fillStaffExcelTable(sheet, accountMap, teacherMap, excelFile);

      // Lưu file cho Giáo viên/Ban giám hiệu
      try {
        final directory = Directory('/storage/emulated/0/Download');
        final path =
            '${directory.path}/nvxxreport_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(path);
        await file.writeAsBytes(excelFile.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File đã được lưu tại: $path')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xuất file: ${e.toString()}')),
        );
      }
    }
  }

  void _fillClassInfo(
      excel.Sheet sheet, String classId, ClassMistakeModel? classInfo) {
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Tên lớp");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(classInfo?.className ?? classId);
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("B2")).value =
        excel.TextCellValue(classInfo?.academicYear ?? selectedYear ?? '');
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Giáo viên chủ nhiệm");
    sheet.cell(excel.CellIndex.indexByString("B3")).value =
        excel.TextCellValue(classInfo?.homeroomTeacher ?? '');
    sheet.cell(excel.CellIndex.indexByString("A4")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B4")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    // Định dạng tiêu đề
    for (int row = 1; row <= 4; row++) {
      sheet.cell(excel.CellIndex.indexByString("A$row")).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Left,
      );
      sheet.cell(excel.CellIndex.indexByString("B$row")).cellStyle =
          excel.CellStyle(
        horizontalAlign: excel.HorizontalAlign.Left,
      );
    }
  }

  Future<void> _fillStudentExcelTable(
      excel.Sheet sheet, List<dynamic> data, excel.Excel excelFile) async {
    const int headerRowIndex = 6;
    const headers = [
      "STT",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Tên tài khoản HS",
      "Mật khẩu HS",
      "Tên tài khoản PHHS",
      "Mật khẩu PHHS",
    ];

    // Ghi header
    for (int col = 0; col < headers.length; col++) {
      final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
          excel.TextCellValue(headers[col]);
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
      );
    }

    // Ghi dữ liệu
    int currentRow = headerRowIndex + 1;
    for (var studentData in data) {
      final account = studentData['account'];
      final student = studentData['student'];
      final detail = studentData['detail'];

      sheet.cell(excel.CellIndex.indexByString("A$currentRow")).value =
          excel.TextCellValue((currentRow - headerRowIndex).toString());
      sheet.cell(excel.CellIndex.indexByString("B$currentRow")).value =
          excel.TextCellValue(
              detail['_studentName'] ?? account['_accName'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("C$currentRow")).value =
          excel.TextCellValue(detail['_birthday'] ?? account['_birth'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("D$currentRow")).value =
          excel.TextCellValue(detail['_gender'] ?? account['_gender'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("E$currentRow")).value =
          excel.TextCellValue(account['_userName'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("F$currentRow")).value =
          excel.TextCellValue(account['_password'] ?? '123');
      // Giả sử PHHS có tài khoản riêng, cần lấy từ collection khác nếu có
      sheet.cell(excel.CellIndex.indexByString("G$currentRow")).value =
          excel.TextCellValue(student['P_id'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("H$currentRow")).value =
          excel.TextCellValue(student['P_password'] ?? '123');

      // Định dạng dữ liệu
      for (int col = 0; col < headers.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
        );
      }
      currentRow++;
    }
  }

  void _fillStaffInfo(excel.Sheet sheet) {
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    sheet.cell(excel.CellIndex.indexByString("A1")).cellStyle = excel.CellStyle(
      bold: true,
      horizontalAlign: excel.HorizontalAlign.Left,
    );
    sheet.cell(excel.CellIndex.indexByString("B1")).cellStyle = excel.CellStyle(
      horizontalAlign: excel.HorizontalAlign.Left,
    );
  }

  Future<void> _fillStaffExcelTable(
      excel.Sheet sheet,
      Map<String, dynamic> accountMap,
      Map<String, dynamic> staffMap,
      excel.Excel excelFile) async {
    const int headerRowIndex = 3;
    const headers = [
      "STT",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Tên đăng nhập",
      "Mật khẩu",
    ];

    // Ghi header
    for (int col = 0; col < headers.length; col++) {
      final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
          excel.TextCellValue(headers[col]);
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
      );
    }

    // Ghi dữ liệu
    int currentRow = headerRowIndex + 1;
    int stt = 1;
    for (var staffId in staffMap.keys) {
      final staff = staffMap[staffId];
      final account = accountMap[staff['ACC_id']];

      sheet.cell(excel.CellIndex.indexByString("A$currentRow")).value =
          excel.TextCellValue(stt.toString());
      sheet.cell(excel.CellIndex.indexByString("B$currentRow")).value =
          excel.TextCellValue(account['_accName'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("C$currentRow")).value =
          excel.TextCellValue(account['_birth'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("D$currentRow")).value =
          excel.TextCellValue(account['_gender'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("E$currentRow")).value =
          excel.TextCellValue(account['_username'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("F$currentRow")).value =
          excel.TextCellValue(account['_password'] ?? '123');

      // Định dạng dữ liệu
      for (int col = 0; col < headers.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
        );
      }
      currentRow++;
      stt++;
    }
  }

  Future<List<dynamic>> _fetchStudentDataOptimized(
      String classId,
      Map<String, dynamic> accountMap,
      Map<String, dynamic> studentMap,
      Map<String, dynamic> studentDetailMap) async {
    final result = [];
    final studentsInClass = studentDetailMap.values
        .where((detail) => detail['Class_id'] == classId);

    for (var detail in studentsInClass) {
      final student = studentMap[detail['ST_id']];
      final account = accountMap[student['ACC_id']];
      result.add({
        'account': account,
        'student': student,
        'detail': detail,
      });
    }
    return result;
  }
  // Future<void> _createSheetsByClassId(excel.Excel excelFile) async {
  //   // Lấy dữ liệu tài khoản
  //   final accountSnapshot = await FirebaseFirestore.instance
  //       .collection('ACCOUNT')
  //       .where('_groupID', isEqualTo: 'hocSinh')
  //       .get();

  //   if (accountSnapshot.docs.isEmpty) return;

  //   final accountMap = {
  //     for (var doc in accountSnapshot.docs) doc['_id'] as String: doc.data()
  //   };
  //   final accIds = accountMap.keys.toList();
  //   print('datad accid $accIds');

  //   // Lấy dữ liệu sinh viên
  //   final studentDocs = await _batchQuery('STUDENT', 'ACC_id', accIds);
  //   final studentMap = {for (var doc in studentDocs) doc['_id'] as String: doc};
  //   final stIds = studentMap.keys.toList();

  //   // Lấy dữ liệu chi tiết sinh viên
  //   final studentDetailDocs =
  //       await _batchQuery('STUDENT_DETAIL', 'ST_id', stIds);
  //   final studentDetailMap = {
  //     for (var doc in studentDetailDocs) doc['ST_id'] as String: doc
  //   };
  //   final allStudentDetailIds = studentDetailMap.keys.toList();

  //   final classIds = studentDetailDocs
  //       .map((doc) => doc['Class_id'] as String?)
  //       .where((id) => id != null && id.isNotEmpty)
  //       .map((id) => id!)
  //       .toSet()
  //       .toList();
  //   print('so luong class id ${classIds.length}');

  //   if (classIds.isEmpty) return;

  //   // Lấy dữ liệu lớp
  //   final classDocsWithSnapshots = await FirebaseFirestore.instance
  //       .collection('CLASS')
  //       .where('_id', whereIn: classIds)
  //       .get();
  //   final classMap = {
  //     for (var doc in classDocsWithSnapshots.docs)
  //       doc.id: ClassMistakeModel.fromFirestore(doc)
  //   };

  //   // Lấy tất cả dữ liệu CONDUCT_MONTH và MISTAKE_MONTH một lần
  //   final allConductSnapshot =
  //       await _batchQuery('CONDUCT_MONTH', 'studentID', allStudentDetailIds);
  //   final allMistakeSnapshot =
  //       await _batchQuery('MISTAKE_MONTH', 'STD_id', allStudentDetailIds);

  //   final allConductDataByStudent = {
  //     for (var doc in allConductSnapshot) doc['studentID'] as String: doc
  //   };
  //   final allMistakeDataByStudent = {
  //     for (var doc in allMistakeSnapshot) doc['STD_id'] as String: doc
  //   };

  //   // Xử lý song song dữ liệu cho tất cả lớp
  //   final futures = classIds.map((classId) async {
  //     return _fetchStudentDataOptimized(
  //       classId,
  //       accountMap,
  //       studentMap,
  //       studentDetailMap,
  //       allConductDataByStudent,
  //       allMistakeDataByStudent,
  //     );
  //   }).toList();

  //   final results = await Future.wait(futures);

  //   // Ghi dữ liệu tuần tự vào Excel
  //   final defaultSheetName = excelFile.getDefaultSheet()!;
  //   excelFile.rename(defaultSheetName, classIds.first);
  //   final firstSheet = excelFile[classIds.first];
  //   _fillClassInfo(firstSheet, classIds.first, classMap[classIds.first]);
  //   await _fillExcelTable(firstSheet, results[0], excelFile);

  //   for (int i = 1; i < classIds.length; i++) {
  //     final classId = classIds[i];
  //     final sheet = excelFile[classId];
  //     _fillClassInfo(sheet, classId, classMap[classId]);
  //     await _fillExcelTable(sheet, results[i], excelFile);
  //   }
  // }

  // void _fillClassInfo(
  //     excel.Sheet sheet, String classId, ClassMistakeModel? classInfo) {
  //   sheet.cell(excel.CellIndex.indexByString("A1")).value =
  //       excel.TextCellValue("Tên lớp");
  //   sheet.cell(excel.CellIndex.indexByString("B1")).value =
  //       excel.TextCellValue(classInfo?.className ?? '');
  //   sheet.cell(excel.CellIndex.indexByString("A2")).value =
  //       excel.TextCellValue("Niên khóa");
  //   sheet.cell(excel.CellIndex.indexByString("B2")).value =
  //       excel.TextCellValue(classInfo?.academicYear ?? '');
  //   sheet.cell(excel.CellIndex.indexByString("A3")).value =
  //       excel.TextCellValue("Giáo viên chủ nhiệm");
  //   sheet.cell(excel.CellIndex.indexByString("B3")).value =
  //       excel.TextCellValue(classInfo?.homeroomTeacher ?? '');
  //   sheet.cell(excel.CellIndex.indexByString("A4")).value =
  //       excel.TextCellValue("Tháng");
  //   sheet.cell(excel.CellIndex.indexByString("B4")).value =
  //       excel.TextCellValue('');
  //   sheet.cell(excel.CellIndex.indexByString("A5")).value =
  //       excel.TextCellValue("Ngày xuất báo cáo");
  //   sheet.cell(excel.CellIndex.indexByString("B5")).value =
  //       excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

  //   const int titleRow = 11;
  //   sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
  //       excel.TextCellValue("BÁO CÁO TỔNG KẾT VI PHẠM HỌC SINH");
  //   sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
  //       excel.CellIndex.indexByString("I$titleRow"));
  //   sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
  //       excel.CellStyle(
  //     bold: true,
  //     fontSize: 14,
  //     horizontalAlign: excel.HorizontalAlign.Center,
  //   );
  // }

  // Future<Map<String, dynamic>> _fetchStudentDataOptimized(
  //   String classId,
  //   Map<String, Map<String, dynamic>> accountMap,
  //   Map<String, Map<String, dynamic>> studentMap,
  //   Map<String, Map<String, dynamic>> studentDetailMap,
  //   Map<String, Map<String, dynamic>> allConductDataByStudent,
  //   Map<String, Map<String, dynamic>> allMistakeDataByStudent,
  // ) async {
  //   List<List<dynamic>> tableData = [];
  //   int stt = 1;

  //   int totalMistakeCount = 0;
  //   Map<String, int> conductCounts = {
  //     'Tốt': 0,
  //     'Khá': 0,
  //     'Đạt': 0,
  //     'Chưa Đạt': 0,
  //   };

  //   // Lọc studentDetailIds theo lớp
  //   final studentDetailIdsForClass = studentDetailMap.values
  //       .where((detail) => detail['Class_id'] == classId)
  //       .map((detail) => detail['_id'] as String)
  //       .toList();

  //   // Đếm tổng số MISTAKE_MONTH và CONDUCT_MONTH từ dữ liệu đã tải
  //   for (var studentDetailId in studentDetailIdsForClass) {
  //     final conductData = allConductDataByStudent[studentDetailId];
  //     if (conductData != null) {
  //       final monthData = conductData['_month']['month10'] as List<dynamic>?;
  //       if (monthData != null && monthData.length >= 2) {
  //         String conduct = monthData[1].toString();
  //         conductCounts[conduct] = (conductCounts[conduct] ?? 0) + 1;
  //       }
  //     }

  //     final mistakeData = allMistakeDataByStudent[studentDetailId];
  //     if (mistakeData != null) {
  //       totalMistakeCount++;
  //     }
  //   }

  //   // Xây dựng tableData
  //   for (var accId in accountMap.keys) {
  //     final student = studentMap.values.firstWhere(
  //       (s) => s['ACC_id'] == accId,
  //       orElse: () => <String, dynamic>{},
  //     );
  //     if (student.isEmpty) continue;

  //     final studentId = student['_id'] as String;
  //     final parentId = student['P_id'] as String?;
  //     final studentDetail = studentDetailMap[studentId];
  //     if (studentDetail == null || studentDetail['Class_id'] != classId)
  //       continue;

  //     final studentDetailId = studentDetail['_id'] as String;
  //     final account = accountMap[accId]!;

  //     String conduct = '';
  //     int trainingScore = 0;
  //     final conductData = allConductDataByStudent[studentDetailId];
  //     if (conductData != null) {
  //       final monthData = conductData['_month']['month10'] as List<dynamic>?;
  //       if (monthData != null && monthData.length >= 2) {
  //         trainingScore = int.tryParse(monthData[0].toString()) ?? 0;
  //         conduct = monthData[1].toString();
  //       }
  //     }

  //     int violationCount = 0;
  //     String violationInfo = '';
  //     final mistakeData = allMistakeDataByStudent[studentDetailId];
  //     if (mistakeData != null) {
  //       violationCount =
  //           1; // Giả sử mỗi tài liệu là 1 vi phạm, cần điều chỉnh nếu có danh sách
  //       violationInfo =
  //           '${mistakeData['M_name']}(${mistakeData['_subject']}+${mistakeData['_time']})';
  //     }

  //     tableData.add([
  //       (stt++).toString(),
  //       studentId,
  //       studentDetail['_studentName'] ?? account['_accName'] ?? '',
  //       studentDetail['_birthday'] ?? account['_birth'] ?? '',
  //       studentDetail['_gender'] ?? account['_gender'] ?? '',
  //       conduct,
  //       trainingScore.toString(),
  //       violationCount.toString(),
  //       violationInfo,
  //     ]);
  //   }

  //   return {
  //     'tableData': tableData,
  //     'totalMistakeCount': totalMistakeCount,
  //     'conductCounts': conductCounts,
  //   };
  // }

  // Future<void> _fillExcelTable(excel.Sheet sheet, Map<String, dynamic> data,
  //     excel.Excel excelFile) async {
  //   final List<List<dynamic>> tableData = data['tableData'];
  //   final int totalMistakeCount = data['totalMistakeCount'];
  //   final Map<String, int> conductCounts = data['conductCounts'];

  //   sheet.cell(excel.CellIndex.indexByString("A7")).value =
  //       excel.TextCellValue("Tổng số lượng vi phạm");
  //   sheet.cell(excel.CellIndex.indexByString("B7")).value =
  //       excel.TextCellValue(totalMistakeCount.toString());
  //   sheet.cell(excel.CellIndex.indexByString("A8")).value =
  //       excel.TextCellValue("Số lượng hạnh kiểm");
  //   sheet.cell(excel.CellIndex.indexByString("B8")).value =
  //       excel.TextCellValue("Hạnh kiểm Tốt");
  //   sheet.cell(excel.CellIndex.indexByString("B9")).value =
  //       excel.TextCellValue(conductCounts['Tốt'].toString());
  //   sheet.cell(excel.CellIndex.indexByString("C8")).value =
  //       excel.TextCellValue("Hạnh kiểm Khá");
  //   sheet.cell(excel.CellIndex.indexByString("C9")).value =
  //       excel.TextCellValue(conductCounts['Khá'].toString());
  //   sheet.cell(excel.CellIndex.indexByString("D8")).value =
  //       excel.TextCellValue("Hạnh kiểm Đạt");
  //   sheet.cell(excel.CellIndex.indexByString("D9")).value =
  //       excel.TextCellValue(conductCounts['Đạt'].toString());
  //   sheet.cell(excel.CellIndex.indexByString("E8")).value =
  //       excel.TextCellValue("Hạnh kiểm Chưa Đạt");
  //   sheet.cell(excel.CellIndex.indexByString("E9")).value =
  //       excel.TextCellValue(conductCounts['Chưa Đạt'].toString());

  //   const int headerRowIndex = 12;
  //   const headers = [
  //     "STT",
  //     "Mã học sinh",
  //     "Họ và tên",
  //     "Ngày sinh",
  //     "Giới tính",
  //     "Hạnh kiểm",
  //     "Điểm rèn luyện",
  //     "Số lượng vi phạm",
  //     "Thông tin các lỗi vi phạm",
  //   ];

  //   for (int col = 0; col < headers.length; col++) {
  //     final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
  //     sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
  //         excel.TextCellValue(headers[col]);
  //     sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
  //         excel.CellStyle(
  //       bold: true,
  //       horizontalAlign: excel.HorizontalAlign.Center,
  //     );
  //   }

  //   int currentRow = headerRowIndex + 1;
  //   for (var rowData in tableData) {
  //     for (int col = 0; col < rowData.length; col++) {
  //       final cellAddress = "${getColumnLetter(col)}$currentRow";
  //       final value = rowData[col];
  //       sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
  //           value is String
  //               ? excel.TextCellValue(value)
  //               : value is int
  //                   ? excel.IntCellValue(value)
  //                   : excel.TextCellValue(value.toString());
  //       sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
  //           excel.CellStyle(
  //         horizontalAlign: excel.HorizontalAlign.Left,
  //         textWrapping: excel.TextWrapping.WrapText,
  //       );
  //     }
  //     currentRow++;
  //   }

  //   try {
  //     final directory = Directory('/storage/emulated/0/Download');
  //     final path =
  //         '${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  //     final file = File(path);
  //     await file.writeAsBytes(excelFile.encode()!);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('File đã được lưu tại: $path')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Lỗi khi xuất file: ${e.toString()}')),
  //     );
  //   }
  // }
}
