import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:provider/provider.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
import 'package:vnclass/modules/main_home/controller/teacher_provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';

class DialogReport extends StatefulWidget {
  final String reportType;

  const DialogReport({super.key, required this.reportType});

  @override
  _DialogReport createState() => _DialogReport();
}

enum PeriodType { semester1, semester2, fullYear, month }

enum PeriodTypes { semester1, semester2, fullYear }

class _DialogReport extends State<DialogReport> {
  String? selectedOption;
  String? selectedMonth;
  String? selectedSemester;
  String? selectedClass;
  String? selectedYear;
  bool isExporting = false;
  String? errorMessage;

  bool get canExport =>
      selectedYear != null &&
      selectedOption != null &&
      (selectedOption == 'Tháng'
          ? selectedMonth != null
          : selectedSemester != null);

  String getColumnLetter(int colIndex) {
    return String.fromCharCode(65 + colIndex);
  }

  Future<void> exportToExcel(BuildContext context) async {
    setState(() => isExporting = true);
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          await _handleAndroid13Permissions(context);
        } else {
          await _handleLegacyAndroidPermissions(context);
        }
      }

      var excelFile = excel.Excel.createExcel();
      if (widget.reportType == 'class') {
        if (selectedOption == 'Tháng') {
          //    await _createSheetsByClassIdForMonth(excelFile, context);
          await _createSheetsByClassId(excelFile, context, PeriodType.month);
        } else if (selectedOption == 'Học kỳ' &&
            selectedSemester == 'Học kỳ 1') {
          // await _createSheetsByClassIdForSemester1(excelFile, context);
          await _createSheetsByClassId(
              excelFile, context, PeriodType.semester1);
        } else if (selectedOption == 'Học kỳ' &&
            selectedSemester == 'Học kỳ 2') {
          await _createSheetsByClassId(
              excelFile, context, PeriodType.semester2);
        } else if (selectedOption == 'Học kỳ' && selectedSemester == 'Cả Năm') {
          await _createSheetsByClassId(excelFile, context, PeriodType.fullYear);
        }
      } else if (widget.reportType == 'school') {
        if (selectedOption == 'Tháng') {
          await _createSheetForSchoolMonth(excelFile, context);
        } else if (selectedOption == 'Học kỳ' &&
            selectedSemester == 'Học kỳ 1') {
          await _createSheetForSchool(
              excelFile, context, PeriodTypes.semester1);
        } else if (selectedOption == 'Học kỳ' &&
            selectedSemester == 'Học kỳ 2') {
          await _createSheetForSchool(
              excelFile, context, PeriodTypes.semester2);
        } else if (selectedOption == 'Học kỳ' && selectedSemester == 'Cả Năm') {
          await _createSheetForSchool(excelFile, context, PeriodTypes.fullYear);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi xuất file: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất file: ${e.toString()}')),
      );
    } finally {
      setState(() => isExporting = false);
    }
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

    debugPrint(
        'Batch query cho collection: $collection, field: $field, ids: $ids');
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

    final result =
        batches.expand((batch) => batch.docs).map((doc) => doc.data()).toList();
    debugPrint('Kết quả batch query cho $collection: $result');
    return result;
  }

  Future<void> _createSheetsByClassId(excel.Excel excelFile,
      BuildContext context, PeriodType periodType) async {
    String periodLabel;
    switch (periodType) {
      case PeriodType.semester1:
        periodLabel = "Học kỳ 1";
        break;
      case PeriodType.semester2:
        periodLabel = "Học kỳ 2";
        break;
      case PeriodType.fullYear:
        periodLabel = "Cả Năm";
        break;
      case PeriodType.month:
        periodLabel = "Tháng";
        break;
    }

    debugPrint(
        'Bắt đầu tạo sheets cho $periodLabel với selectedYear: $selectedYear, selectedClass: $selectedClass');

    Query<Map<String, dynamic>> classQuery = FirebaseFirestore.instance
        .collection('CLASS')
        .where('_year', isEqualTo: selectedYear);

    if (selectedClass != null && selectedClass != 'Tất cả') {
      classQuery = classQuery.where('_className', isEqualTo: selectedClass);
    }

    final classSnapshot = await classQuery.get();
    final classDocs = classSnapshot.docs;
    final classIds = classDocs.map((doc) => doc.id).toList();
    if (classIds.isEmpty) return;

    final studentDetailSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', whereIn: classIds)
        .get();
    final studentDetailMap = {
      for (var doc in studentDetailSnapshot.docs) doc.id: doc.data()
    };
    final allStudentDetailIds = studentDetailMap.keys.toList();

    final allConductSnapshot =
        await _batchQuery('CONDUCT_MONTH', 'STDL_id', allStudentDetailIds);
    final allMistakeSnapshot =
        await _batchQuery('MISTAKE_MONTH', 'STD_id', allStudentDetailIds);

    final allConductDataByStudent = {
      for (var doc in allConductSnapshot) doc['STDL_id'] as String: doc
    };
    final allMistakeDataByStudentList = allMistakeSnapshot;

    final accountSnapshot = await FirebaseFirestore.instance
        .collection('ACCOUNT')
        .where('_groupID', isEqualTo: 'hocSinh')
        .get();
    final accountMap = {
      for (var doc in accountSnapshot.docs) doc.id: doc.data()
    };
    final accIds = accountMap.keys.toList();

    final studentSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT')
        .where('ACC_id', whereIn: accIds)
        .get();
    final studentMap = {
      for (var doc in studentSnapshot.docs) doc.id: doc.data()
    };

    final futures = classIds.map((classId) async {
      switch (periodType) {
        case PeriodType.semester1:
          return _fetchStudentDataOptimizedForSemester1(
              classId,
              accountMap,
              studentMap,
              studentDetailMap,
              allConductDataByStudent,
              allMistakeDataByStudentList);
        case PeriodType.semester2:
          return _fetchStudentDataOptimizedForSemester2(
              classId,
              accountMap,
              studentMap,
              studentDetailMap,
              allConductDataByStudent,
              allMistakeDataByStudentList);
        case PeriodType.fullYear:
          return _fetchStudentDataOptimizedForSemester3(
              classId,
              accountMap,
              studentMap,
              studentDetailMap,
              allConductDataByStudent,
              allMistakeDataByStudentList);
        case PeriodType.month:
          return _fetchStudentDataOptimizedForMonth(
              classId,
              accountMap,
              studentMap,
              studentDetailMap,
              allConductDataByStudent,
              allMistakeDataByStudentList,
              selectedMonth!);
      }
    }).toList();

    final results = await Future.wait(futures);

    for (int i = 0; i < classIds.length; i++) {
      final classId = classIds[i];
      final classDoc = classDocs[i];
      final className = classDoc['_className'] as String;

      excel.Sheet sheet;
      if (i == 0) {
        final defaultSheetName = excelFile.getDefaultSheet()!;
        excelFile.rename(defaultSheetName, className);
        sheet = excelFile[className];
      } else {
        sheet = excelFile[className];
      }

      switch (periodType) {
        case PeriodType.semester1:
          _fillClassInfoForSemester(sheet, classId, classDoc, 'Học kỳ 1');
          await _fillExcelTableForSemester1(sheet, results[i], excelFile);
          break;
        case PeriodType.semester2:
          _fillClassInfoForSemester(sheet, classId, classDoc, 'Học kỳ 2');
          await _fillExcelTableForSemester2(sheet, results[i], excelFile);
          break;
        case PeriodType.fullYear:
          _fillClassInfoForSemester(sheet, classId, classDoc, 'Cả Năm');
          await _fillExcelTableForSemester3(sheet, results[i], excelFile);
          break;
        case PeriodType.month:
          _fillClassInfoForMonth(sheet, classId, classDoc);
          await _fillExcelTableForMonth(sheet, results[i], excelFile);
          break;
      }
    }

    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final fileName = _getFileName();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(excelFile.encode()!);

    debugPrint('File Excel đã được lưu tại: $path');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File đã được lưu tại: $path')),
    );
  }

  // Logic cho "Tháng" (giữ nguyên)

  void _fillClassInfoForMonth(excel.Sheet sheet, String classId,
      QueryDocumentSnapshot<Map<String, dynamic>> classDoc) {
    final classData = classDoc.data();
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Tên lớp");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(classData['_className'] ?? '');
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("B2")).value =
        excel.TextCellValue(classData['_year'] ?? '');
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Giáo viên chủ nhiệm");
    sheet.cell(excel.CellIndex.indexByString("B3")).value =
        excel.TextCellValue(classData['T_name'] ?? '');
    sheet.cell(excel.CellIndex.indexByString("A4")).value =
        excel.TextCellValue("Tháng");
    sheet.cell(excel.CellIndex.indexByString("B4")).value =
        excel.TextCellValue(selectedMonth ?? '');
    sheet.cell(excel.CellIndex.indexByString("A5")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B5")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    const int titleRow = 11;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
        excel.TextCellValue("BÁO CÁO TỔNG KẾT VI PHẠM HỌC SINH");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
        excel.CellIndex.indexByString("I$titleRow"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
  }

  Future<Map<String, dynamic>> _fetchStudentDataOptimizedForMonth(
    String classId,
    Map<String, Map<String, dynamic>> accountMap,
    Map<String, Map<String, dynamic>> studentMap,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
    List<Map<String, dynamic>> allMistakeDataByStudentList,
    String selectedMonth,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId: $classId');

    List<List<dynamic>> tableData = [];
    int stt = 1;

    int totalMistakeCount = 0;
    Map<String, int> conductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint('studentDetailIdsForClass: $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        final monthData = conductData['_month']
                ['month${selectedMonth.replaceAll('Tháng ', '')}']
            as List<dynamic>?;
        if (monthData != null && monthData.length >= 2) {
          String conduct = monthData[1].toString();
          conductCounts[conduct] = (conductCounts[conduct] ?? 0) + 1;
          debugPrint('Hạnh kiểm cho $studentDetailId: $conduct');
        }
      }

      final mistakes = allMistakeDataByStudentList
          .where((mistake) =>
              mistake['STD_id'] == studentDetailId &&
              mistake['_month'] ==
                  'Tháng ${selectedMonth.replaceAll('Tháng ', '')}')
          .toList();
      totalMistakeCount += mistakes.length;
      debugPrint(
          'Số lượng vi phạm cho $studentDetailId: ${mistakes.length}, Chi tiết: $mistakes');
    }

    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;
      final student = studentMap[studentDetail['ST_id']] ?? {};
      final account = accountMap[student['ACC_id']] ?? {};

      String conduct = '';
      int trainingScore = 0;
      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        final monthData = conductData['_month']
                ['month${selectedMonth.replaceAll('Tháng ', '')}']
            as List<dynamic>?;
        if (monthData != null && monthData.length >= 2) {
          trainingScore = int.tryParse(monthData[0].toString()) ?? 0;
          conduct = monthData[1].toString();
        }
      }

      final mistakes = allMistakeDataByStudentList
          .where((mistake) =>
              mistake['STD_id'] == studentDetailId &&
              mistake['_month'] ==
                  'Tháng ${selectedMonth.replaceAll('Tháng ', '')}')
          .toList();
      int violationCount = mistakes.length;
      String violationInfo = mistakes
          .map((mistake) =>
              '${mistake['M_name']}(${mistake['_subject']}+${mistake['_time']})')
          .join(', ');

      final rowData = [
        (stt++).toString(),
        studentDetail['ST_id'] ?? '',
        studentDetail['_studentName'] ?? account['_accName'] ?? '',
        studentDetail['_birthday'] ?? account['_birth'] ?? '',
        studentDetail['_gender'] ?? account['_gender'] ?? '',
        conduct,
        trainingScore.toString(),
        violationCount.toString(),
        violationInfo,
      ];
      tableData.add(rowData);
      debugPrint('Dòng dữ liệu cho $studentDetailId: $rowData');
    }

    final result = {
      'tableData': tableData,
      'totalMistakeCount': totalMistakeCount,
      'conductCounts': conductCounts,
    };
    debugPrint('Kết quả xử lý cho $classId: $result');

    return result;
  }

  Future<void> _fillExcelTableForMonth(excel.Sheet sheet,
      Map<String, dynamic> data, excel.Excel excelFile) async {
    final List<List<dynamic>> tableData = data['tableData'];
    final int totalMistakeCount = data['totalMistakeCount'];
    final Map<String, int> conductCounts = data['conductCounts'];

    sheet.cell(excel.CellIndex.indexByString("A7")).value =
        excel.TextCellValue("Tổng số lượng vi phạm");
    sheet.cell(excel.CellIndex.indexByString("B7")).value =
        excel.TextCellValue(totalMistakeCount.toString());
    sheet.cell(excel.CellIndex.indexByString("A8")).value =
        excel.TextCellValue("Số lượng hạnh kiểm");
    sheet.cell(excel.CellIndex.indexByString("B8")).value =
        excel.TextCellValue("Hạnh kiểm Tốt");
    sheet.cell(excel.CellIndex.indexByString("B9")).value =
        excel.TextCellValue(conductCounts['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C8")).value =
        excel.TextCellValue("Hạnh kiểm Khá");
    sheet.cell(excel.CellIndex.indexByString("C9")).value =
        excel.TextCellValue(conductCounts['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D8")).value =
        excel.TextCellValue("Hạnh kiểm Đạt");
    sheet.cell(excel.CellIndex.indexByString("D9")).value =
        excel.TextCellValue(conductCounts['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E8")).value =
        excel.TextCellValue("Hạnh kiểm Chưa Đạt");
    sheet.cell(excel.CellIndex.indexByString("E9")).value =
        excel.TextCellValue(conductCounts['Chưa Đạt'].toString());

    const int headerRowIndex = 12;
    const headers = [
      "STT",
      "Mã học sinh",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Hạnh kiểm",
      "Điểm rèn luyện",
      "Số lượng vi phạm",
      "Thông tin các lỗi vi phạm",
    ];

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

    int currentRow = headerRowIndex + 1;
    for (var rowData in tableData) {
      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        final value = rowData[col];
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            value is String
                ? excel.TextCellValue(value)
                : value is int
                    ? excel.IntCellValue(value)
                    : excel.TextCellValue(value.toString());
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  // Logic cho "Học kỳ 1"

  void _fillClassInfoForSemester(excel.Sheet sheet, String classId,
      QueryDocumentSnapshot<Map<String, dynamic>> classDoc, String hocky) {
    final classData = classDoc.data();
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Tên lớp");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(classData['_className'] ?? '');
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("B2")).value =
        excel.TextCellValue(classData['_year'] ?? '');
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Giáo viên chủ nhiệm");
    sheet.cell(excel.CellIndex.indexByString("B3")).value =
        excel.TextCellValue(classData['T_name'] ?? '');
    sheet.cell(excel.CellIndex.indexByString("A4")).value =
        excel.TextCellValue("Học kỳ");
    sheet.cell(excel.CellIndex.indexByString("B4")).value =
        excel.TextCellValue(hocky);
    sheet.cell(excel.CellIndex.indexByString("A5")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B5")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    const int titleRow1 = 7;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow1")).value =
        excel.TextCellValue(
            "BÁO CÁO TỔNG KẾT TỔNG QUÁT ${hocky.toUpperCase()} VI PHẠM HỌC SINH");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow1"),
        excel.CellIndex.indexByString("E$titleRow1"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow1")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );

    const int titleRow2 = 14;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow2")).value =
        excel.TextCellValue(
            "BÁO CÁO TỔNG KẾT ${hocky.toUpperCase()} VI PHẠM HỌC SINH");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow2"),
        excel.CellIndex.indexByString("J$titleRow2"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow2")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
  }

  Future<Map<String, dynamic>> _fetchStudentDataOptimizedForSemester1(
    String classId,
    Map<String, Map<String, dynamic>> accountMap,
    Map<String, Map<String, dynamic>> studentMap,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
    List<Map<String, dynamic>> allMistakeDataByStudentList,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (Học kỳ 1): $classId');

    List<List<dynamic>> tableData = [];
    int stt = 1;

    // Đếm số lượng hạnh kiểm cho từng tháng
    Map<String, Map<String, int>> monthlyConductCounts = {
      '9': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '10': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '11': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '12': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
    };
    Map<String, int> semesterConductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (Học kỳ 1): $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        for (var month in ['9', '10', '11', '12']) {
          final monthData =
              conductData['_month']['month$month'] as List<dynamic>?;
          if (monthData != null && monthData.length >= 2) {
            String conduct = monthData[1].toString();
            monthlyConductCounts[month]![conduct] =
                (monthlyConductCounts[month]![conduct] ?? 0) + 1;
            debugPrint('Hạnh kiểm tháng $month cho $studentDetailId: $conduct');
          }
        }
      }
    }

    // Xây dựng tableData và tính tổng kết Học kỳ 1 dựa trên điểm trung bình từ CONDUCT_MONTH
    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;
      final student = studentMap[studentDetail['ST_id']] ?? {};
      final account = accountMap[student['ACC_id']] ?? {};

      String conduct9 = '',
          conduct10 = '',
          conduct11 = '',
          conduct12 = '',
          semesterConduct = studentDetail['_conductTerm1'];
      int score9 = 0, score10 = 0, score11 = 0, score12 = 0;
      semesterConductCounts[semesterConduct] =
          (semesterConductCounts[semesterConduct] ?? 0) + 1;
      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        for (var month in ['9', '10', '11', '12']) {
          final monthData =
              conductData['_month']['month$month'] as List<dynamic>?;
          if (monthData != null && monthData.length >= 2) {
            int score = int.tryParse(monthData[0].toString()) ?? 0;
            String conduct = monthData[1].toString();
            switch (month) {
              case '9':
                score9 = score;
                conduct9 = conduct;
                break;
              case '10':
                score10 = score;
                conduct10 = conduct;
                break;
              case '11':
                score11 = score;
                conduct11 = conduct;
                break;
              case '12':
                score12 = score;
                conduct12 = conduct;
                break;
            }
          }
        }
      }

      final rowData = [
        (stt++).toString(),
        studentDetail['ST_id'] ?? '',
        studentDetail['_studentName'] ?? account['_accName'] ?? '',
        studentDetail['_birthday'] ?? account['_birth'] ?? '',
        studentDetail['_gender'] ?? account['_gender'] ?? '',
        conduct9.isNotEmpty ? '$conduct9 - $score9' : '',
        conduct10.isNotEmpty ? '$conduct10 - $score10' : '',
        conduct11.isNotEmpty ? '$conduct11 - $score11' : '',
        conduct12.isNotEmpty ? '$conduct12 - $score12' : '',
        studentDetail['_conductTerm1'],
      ];
      tableData.add(rowData);
      debugPrint('Dòng dữ liệu cho $studentDetailId (Học kỳ 1): $rowData');
    }

    final result = {
      'tableData': tableData,
      'monthlyConductCounts': monthlyConductCounts,
      'semesterConductCounts': semesterConductCounts,
    };
    debugPrint('Kết quả xử lý cho $classId (Học kỳ 1): $result');

    return result;
  }

  Future<Map<String, dynamic>> _fetchStudentDataOptimizedForSemester3(
    String classId,
    Map<String, Map<String, dynamic>> accountMap,
    Map<String, Map<String, dynamic>> studentMap,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
    List<Map<String, dynamic>> allMistakeDataByStudentList,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (Học kỳ cả năm): $classId');

    List<List<dynamic>> tableData = [];
    int stt = 1;

    Map<String, int> semesterConductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0
    };
    Map<String, int> semesterConductCounts1 = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0
    };
    Map<String, int> semesterConductCounts2 = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (Học kỳ cả năm): $studentDetailIdsForClass');

    // Xây dựng tableData và tính tổng kết Học kỳ 1 dựa trên điểm trung bình từ CONDUCT_MONTH
    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;
      final student = studentMap[studentDetail['ST_id']] ?? {};
      final account = accountMap[student['ACC_id']] ?? {};

      String semesterConduct1 = studentDetail['_conductTerm1'],
          semesterConduct2 = studentDetail['_conductTerm2'],
          semesterConduct = studentDetail['_conductAllYear'];

      semesterConductCounts[semesterConduct] =
          (semesterConductCounts[semesterConduct] ?? 0) + 1;

      semesterConductCounts1[semesterConduct1] =
          (semesterConductCounts1[semesterConduct1] ?? 0) + 1;

      semesterConductCounts2[semesterConduct2] =
          (semesterConductCounts2[semesterConduct2] ?? 0) + 1;

      final rowData = [
        (stt++).toString(),
        studentDetail['ST_id'] ?? '',
        studentDetail['_studentName'] ?? account['_accName'] ?? '',
        studentDetail['_birthday'] ?? account['_birth'] ?? '',
        studentDetail['_gender'] ?? account['_gender'] ?? '',
        semesterConduct1,
        semesterConduct2,
        semesterConduct,
      ];
      tableData.add(rowData);
      debugPrint('Dòng dữ liệu cho $studentDetailId (Học kỳ cả năm): $rowData');
    }

    final result = {
      'tableData': tableData,
      'semesterConductCounts': semesterConductCounts,
      'semesterConductCounts1': semesterConductCounts1,
      'semesterConductCounts2': semesterConductCounts2,
    };
    debugPrint('Kết quả xử lý cho $classId (Học kỳ 1): $result');

    return result;
  }

  Future<Map<String, dynamic>> _fetchStudentDataOptimizedForSemester2(
    String classId,
    Map<String, Map<String, dynamic>> accountMap,
    Map<String, Map<String, dynamic>> studentMap,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
    List<Map<String, dynamic>> allMistakeDataByStudentList,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (Học kỳ 2): $classId');

    List<List<dynamic>> tableData = [];
    int stt = 1;

    // Đếm số lượng hạnh kiểm cho từng tháng
    Map<String, Map<String, int>> monthlyConductCounts = {
      '1': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '2': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '3': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '4': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '5': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
    };
    Map<String, int> semesterConductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (Học kỳ 2): $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        for (var month in ['1', '2', '3', '4', '5']) {
          final monthData =
              conductData['_month']['month$month'] as List<dynamic>?;
          if (monthData != null && monthData.length >= 2) {
            String conduct = monthData[1].toString();
            monthlyConductCounts[month]![conduct] =
                (monthlyConductCounts[month]![conduct] ?? 0) + 1;
            debugPrint('Hạnh kiểm tháng $month cho $studentDetailId: $conduct');
          }
        }
      }
    }

    // Xây dựng tableData và đếm semesterConductCounts từ _conductTerm2
    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;
      final student = studentMap[studentDetail['ST_id']] ?? {};
      final account = accountMap[student['ACC_id']] ?? {};

      String conduct1 = '',
          conduct2 = '',
          conduct3 = '',
          conduct4 = '',
          conduct5 = '';
      String score1 = '', score2 = '', score3 = '', score4 = '', score5 = '';
      String semesterConduct =
          studentDetail['_conductTerm2']?.toString().trim() ??
              ''; // Loại bỏ khoảng trắng thừa

      // Debug giá trị _conductTerm2 trước khi đếm
      debugPrint(
          'Giá trị _conductTerm2 cho $studentDetailId trước khi đếm: "$semesterConduct"');

      // Đếm semesterConduct nếu giá trị không rỗng
      if (semesterConduct.isNotEmpty) {
        semesterConductCounts[semesterConduct] =
            (semesterConductCounts[semesterConduct] ?? 0) + 1;
        debugPrint(
            'Đã đếm $semesterConduct vào semesterConductCounts: $semesterConductCounts');
      } else {
        debugPrint(
            'Không đếm: _conductTerm2 rỗng hoặc null cho $studentDetailId');
      }

      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        for (var month in ['1', '2', '3', '4', '5']) {
          final monthData =
              conductData['_month']['month$month'] as List<dynamic>?;
          if (monthData != null && monthData.length >= 2) {
            String conduct = monthData[1].toString();
            String score = monthData[0].toString();
            switch (month) {
              case '1':
                score1 = score;
                conduct1 = conduct;
                break;
              case '2':
                score2 = score;
                conduct2 = conduct;
                break;
              case '3':
                score3 = score;
                conduct3 = conduct;
                break;
              case '4':
                score4 = score;
                conduct4 = conduct;
                break;
              case '5':
                score5 = score;
                conduct5 = conduct;
                break;
            }
          }
        }
      }

      final rowData = [
        (stt++).toString(),
        studentDetail['ST_id'] ?? '',
        studentDetail['_studentName'] ?? account['_accName'] ?? '',
        studentDetail['_birthday'] ?? account['_birth'] ?? '',
        studentDetail['_gender'] ?? account['_gender'] ?? '',
        conduct1.isNotEmpty ? '$conduct1 - $score1' : '',
        conduct2.isNotEmpty ? '$conduct2 - $score2' : '',
        conduct3.isNotEmpty ? '$conduct3 - $score3' : '',
        conduct4.isNotEmpty ? '$conduct4 - $score4' : '',
        conduct5.isNotEmpty ? '$conduct5 - $score5' : '',
        semesterConduct,
      ];
      tableData.add(rowData);
      debugPrint('Dòng dữ liệu cho $studentDetailId (Học kỳ 2): $rowData');
    }

    final result = {
      'tableData': tableData,
      'monthlyConductCounts': monthlyConductCounts,
      'semesterConductCounts': semesterConductCounts,
    };
    debugPrint('Kết quả xử lý cho $classId (Học kỳ 2): $result');
    print("du lieu học $result");
    return result;
  }

  Future<void> _fillExcelTableForSemester1(excel.Sheet sheet,
      Map<String, dynamic> data, excel.Excel excelFile) async {
    final List<List<dynamic>> tableData = data['tableData'];
    final Map<String, Map<String, int>> monthlyConductCounts =
        data['monthlyConductCounts'];
    final Map<String, int> semesterConductCounts =
        data['semesterConductCounts'];

    // Điền số lượng hạnh kiểm cho từng tháng và tổng kết học kỳ
    sheet.cell(excel.CellIndex.indexByString("A9")).value =
        excel.TextCellValue("Số lượng hạnh kiểm");
    sheet.cell(excel.CellIndex.indexByString("B9")).value =
        excel.TextCellValue("Hạnh kiểm Tốt");
    sheet.cell(excel.CellIndex.indexByString("C9")).value =
        excel.TextCellValue("Hạnh kiểm Khá");
    sheet.cell(excel.CellIndex.indexByString("D9")).value =
        excel.TextCellValue("Hạnh kiểm Đạt");
    sheet.cell(excel.CellIndex.indexByString("E9")).value =
        excel.TextCellValue("Hạnh kiểm Chưa Đạt");

    sheet.cell(excel.CellIndex.indexByString("A10")).value =
        excel.TextCellValue("Tháng 9");
    sheet.cell(excel.CellIndex.indexByString("B10")).value =
        excel.TextCellValue(monthlyConductCounts['9']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C10")).value =
        excel.TextCellValue(monthlyConductCounts['9']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D10")).value =
        excel.TextCellValue(monthlyConductCounts['9']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E10")).value =
        excel.TextCellValue(monthlyConductCounts['9']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A11")).value =
        excel.TextCellValue("Tháng 10");
    sheet.cell(excel.CellIndex.indexByString("B11")).value =
        excel.TextCellValue(monthlyConductCounts['10']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C11")).value =
        excel.TextCellValue(monthlyConductCounts['10']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D11")).value =
        excel.TextCellValue(monthlyConductCounts['10']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E11")).value =
        excel.TextCellValue(monthlyConductCounts['10']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A12")).value =
        excel.TextCellValue("Tháng 11");
    sheet.cell(excel.CellIndex.indexByString("B12")).value =
        excel.TextCellValue(monthlyConductCounts['11']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C12")).value =
        excel.TextCellValue(monthlyConductCounts['11']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D12")).value =
        excel.TextCellValue(monthlyConductCounts['11']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E12")).value =
        excel.TextCellValue(monthlyConductCounts['11']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A13")).value =
        excel.TextCellValue("Tháng 12");
    sheet.cell(excel.CellIndex.indexByString("B13")).value =
        excel.TextCellValue(monthlyConductCounts['12']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C13")).value =
        excel.TextCellValue(monthlyConductCounts['12']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D13")).value =
        excel.TextCellValue(monthlyConductCounts['12']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E13")).value =
        excel.TextCellValue(monthlyConductCounts['12']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A14")).value =
        excel.TextCellValue("Học Kỳ 1");
    sheet.cell(excel.CellIndex.indexByString("B14")).value =
        excel.TextCellValue(semesterConductCounts['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C14")).value =
        excel.TextCellValue(semesterConductCounts['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D14")).value =
        excel.TextCellValue(semesterConductCounts['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E14")).value =
        excel.TextCellValue(semesterConductCounts['Chưa Đạt'].toString());

    // Điền bảng chi tiết học sinh
    const int headerRowIndex = 15;
    const headers = [
      "STT",
      "Mã học sinh",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Kết quả Tháng 9",
      "Kết quả Tháng 10",
      "Kết quả Tháng 11",
      "Kết quả Tháng 12",
      "Kết quả Học Kỳ 1",
    ];

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

    int currentRow = headerRowIndex + 1;
    for (var rowData in tableData) {
      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        final value = rowData[col];
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(value.toString());
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  Future<void> _fillExcelTableForSemester2(excel.Sheet sheet,
      Map<String, dynamic> data, excel.Excel excelFile) async {
    final List<List<dynamic>> tableData = data['tableData'];
    final Map<String, Map<String, int>> monthlyConductCounts =
        data['monthlyConductCounts'];
    final Map<String, int> semesterConductCounts =
        data['semesterConductCounts'];

    // Điền số lượng hạnh kiểm cho từng tháng và tổng kết học kỳ
    sheet.cell(excel.CellIndex.indexByString("A9")).value =
        excel.TextCellValue("Số lượng hạnh kiểm");
    sheet.cell(excel.CellIndex.indexByString("B9")).value =
        excel.TextCellValue("Hạnh kiểm Tốt");
    sheet.cell(excel.CellIndex.indexByString("C9")).value =
        excel.TextCellValue("Hạnh kiểm Khá");
    sheet.cell(excel.CellIndex.indexByString("D9")).value =
        excel.TextCellValue("Hạnh kiểm Đạt");
    sheet.cell(excel.CellIndex.indexByString("E9")).value =
        excel.TextCellValue("Hạnh kiểm Chưa Đạt");

    sheet.cell(excel.CellIndex.indexByString("A10")).value =
        excel.TextCellValue("Tháng 1");
    sheet.cell(excel.CellIndex.indexByString("B10")).value =
        excel.TextCellValue(monthlyConductCounts['1']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C10")).value =
        excel.TextCellValue(monthlyConductCounts['1']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D10")).value =
        excel.TextCellValue(monthlyConductCounts['1']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E10")).value =
        excel.TextCellValue(monthlyConductCounts['1']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A11")).value =
        excel.TextCellValue("Tháng 2");
    sheet.cell(excel.CellIndex.indexByString("B11")).value =
        excel.TextCellValue(monthlyConductCounts['2']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C11")).value =
        excel.TextCellValue(monthlyConductCounts['2']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D11")).value =
        excel.TextCellValue(monthlyConductCounts['2']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E11")).value =
        excel.TextCellValue(monthlyConductCounts['2']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A12")).value =
        excel.TextCellValue("Tháng 3");
    sheet.cell(excel.CellIndex.indexByString("B12")).value =
        excel.TextCellValue(monthlyConductCounts['3']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C12")).value =
        excel.TextCellValue(monthlyConductCounts['3']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D12")).value =
        excel.TextCellValue(monthlyConductCounts['3']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E12")).value =
        excel.TextCellValue(monthlyConductCounts['3']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A13")).value =
        excel.TextCellValue("Tháng 4");
    sheet.cell(excel.CellIndex.indexByString("B13")).value =
        excel.TextCellValue(monthlyConductCounts['4']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C13")).value =
        excel.TextCellValue(monthlyConductCounts['4']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D13")).value =
        excel.TextCellValue(monthlyConductCounts['4']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E13")).value =
        excel.TextCellValue(monthlyConductCounts['4']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A14")).value =
        excel.TextCellValue("Tháng 5");
    sheet.cell(excel.CellIndex.indexByString("B14")).value =
        excel.TextCellValue(monthlyConductCounts['5']!['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C14")).value =
        excel.TextCellValue(monthlyConductCounts['5']!['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D14")).value =
        excel.TextCellValue(monthlyConductCounts['5']!['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E14")).value =
        excel.TextCellValue(monthlyConductCounts['5']!['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A15")).value =
        excel.TextCellValue("Học Kỳ 2");
    sheet.cell(excel.CellIndex.indexByString("B15")).value =
        excel.TextCellValue(semesterConductCounts['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C15")).value =
        excel.TextCellValue(semesterConductCounts['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D15")).value =
        excel.TextCellValue(semesterConductCounts['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E15")).value =
        excel.TextCellValue(semesterConductCounts['Chưa Đạt'].toString());

    // Điền bảng chi tiết học sinh
    const int headerRowIndex = 16;
    const headers = [
      "STT",
      "Mã học sinh",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Kết quả Tháng 1",
      "Kết quả Tháng 2",
      "Kết quả Tháng 3",
      "Kết quả Tháng 4",
      "Kết quả Tháng 5",
      "Kết quả Học Kỳ 2",
    ];

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

    int currentRow = headerRowIndex + 1;
    for (var rowData in tableData) {
      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        final value = rowData[col];
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(value.toString());
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  Future<void> _fillExcelTableForSemester3(excel.Sheet sheet,
      Map<String, dynamic> data, excel.Excel excelFile) async {
    final List<List<dynamic>> tableData = data['tableData'];

    final Map<String, int> semesterConductCounts =
        data['semesterConductCounts'];
    final Map<String, int> semesterConductCounts1 =
        data['semesterConductCounts1'];
    final Map<String, int> semesterConductCounts2 =
        data['semesterConductCounts2'];

    // Điền số lượng hạnh kiểm cho từng tháng và tổng kết học kỳ
    sheet.cell(excel.CellIndex.indexByString("A9")).value =
        excel.TextCellValue("Số lượng hạnh kiểm");
    sheet.cell(excel.CellIndex.indexByString("B9")).value =
        excel.TextCellValue("Hạnh kiểm Tốt");
    sheet.cell(excel.CellIndex.indexByString("C9")).value =
        excel.TextCellValue("Hạnh kiểm Khá");
    sheet.cell(excel.CellIndex.indexByString("D9")).value =
        excel.TextCellValue("Hạnh kiểm Đạt");
    sheet.cell(excel.CellIndex.indexByString("E9")).value =
        excel.TextCellValue("Hạnh kiểm Chưa Đạt");

    sheet.cell(excel.CellIndex.indexByString("A10")).value =
        excel.TextCellValue("Học kỳ 1");
    sheet.cell(excel.CellIndex.indexByString("B10")).value =
        excel.TextCellValue(semesterConductCounts1['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C10")).value =
        excel.TextCellValue(semesterConductCounts1['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D10")).value =
        excel.TextCellValue(semesterConductCounts1['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E10")).value =
        excel.TextCellValue(semesterConductCounts1['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A11")).value =
        excel.TextCellValue("Học kỳ 2");
    sheet.cell(excel.CellIndex.indexByString("B11")).value =
        excel.TextCellValue(semesterConductCounts2['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C11")).value =
        excel.TextCellValue(semesterConductCounts2['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D11")).value =
        excel.TextCellValue(semesterConductCounts2['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E11")).value =
        excel.TextCellValue(semesterConductCounts2['Chưa Đạt'].toString());

    sheet.cell(excel.CellIndex.indexByString("A12")).value =
        excel.TextCellValue("Cả năm");
    sheet.cell(excel.CellIndex.indexByString("B12")).value =
        excel.TextCellValue(semesterConductCounts['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C12")).value =
        excel.TextCellValue(semesterConductCounts['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D12")).value =
        excel.TextCellValue(semesterConductCounts['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E12")).value =
        excel.TextCellValue(semesterConductCounts['Chưa Đạt'].toString());

    // Điền bảng chi tiết học sinh
    const int headerRowIndex = 15;
    const headers = [
      "STT",
      "Mã học sinh",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Kết quả HK1",
      "Kết quả HK2",
      "Kết quả Cả năm",
    ];

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

    int currentRow = headerRowIndex + 1;
    for (var rowData in tableData) {
      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        final value = rowData[col];
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(value.toString());
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

// Logic mới cho "Tháng" với reportType = 'school'
  Future<void> _createSheetForSchoolMonth(
      excel.Excel excelFile, BuildContext context) async {
    debugPrint(
        'Bắt đầu tạo sheet cho Tháng (School) với selectedYear: $selectedYear');

    Query<Map<String, dynamic>> classQuery = FirebaseFirestore.instance
        .collection('CLASS')
        .where('_year', isEqualTo: selectedYear);

    final classSnapshot = await classQuery.get();
    final classDocs = classSnapshot.docs;
    final classIds = classDocs.map((doc) => doc.id).toList();
    debugPrint('Danh sách classIds: $classIds');

    if (classIds.isEmpty) {
      debugPrint('Không tìm thấy lớp nào phù hợp');
      return;
    }

    final studentDetailSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', whereIn: classIds)
        .get();
    final studentDetailMap = {
      for (var doc in studentDetailSnapshot.docs) doc.id: doc.data()
    };
    final allStudentDetailIds = studentDetailMap.keys.toList();
    debugPrint('Danh sách studentDetailIds: $allStudentDetailIds');
    debugPrint('Dữ liệu studentDetailMap: $studentDetailMap');

    final allConductSnapshot =
        await _batchQuery('CONDUCT_MONTH', 'STDL_id', allStudentDetailIds);
    final allMistakeSnapshot =
        await _batchQuery('MISTAKE_MONTH', 'STD_id', allStudentDetailIds);

    final allConductDataByStudent = {
      for (var doc in allConductSnapshot) doc['STDL_id'] as String: doc
    };
    final allMistakeDataByStudentList = allMistakeSnapshot;
    debugPrint('Dữ liệu CONDUCT_MONTH: $allConductDataByStudent');
    debugPrint('Dữ liệu MISTAKE_MONTH: $allMistakeDataByStudentList');

    final accountSnapshot = await FirebaseFirestore.instance
        .collection('ACCOUNT')
        .where('_groupID', isEqualTo: 'hocSinh')
        .get();
    final accountMap = {
      for (var doc in accountSnapshot.docs) doc.id: doc.data()
    };
    final accIds = accountMap.keys.toList();
    debugPrint('Danh sách accIds: $accIds');
    debugPrint('Dữ liệu accountMap: $accountMap');

    final studentSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT')
        .where('ACC_id', whereIn: accIds)
        .get();
    final studentMap = {
      for (var doc in studentSnapshot.docs) doc.id: doc.data()
    };
    debugPrint('Dữ liệu studentMap: $studentMap');

    final futures = classIds.map((classId) async {
      return _fetchClassDataForSchoolMonth(
        classId,
        classDocs.firstWhere((doc) => doc.id == classId).data(),
        studentDetailMap,
        allConductDataByStudent,
        allMistakeDataByStudentList,
        selectedMonth!,
      );
    }).toList();

    final results = await Future.wait(futures);
    debugPrint('Kết quả xử lý dữ liệu cho toàn trường (Tháng): $results');

    // Sử dụng sheet mặc định và ghi đè lên đó
    final defaultSheetName = excelFile
        .getDefaultSheet()!; // Lấy tên sheet mặc định (thường là "Sheet1")
    final sheet = excelFile[defaultSheetName]; // Lấy sheet mặc định

    // Ghi đè dữ liệu lên sheet mặc định
    _fillSchoolInfoForMonth(sheet, results);
    await _fillSchoolTableForMonth(sheet, results);

    // Lưu file Excel
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final fileName = _getFileName();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(excelFile.encode()!);
    debugPrint('File Excel duy nhất cho School (Tháng) đã được lưu tại: $path');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File đã được lưu tại: $path')),
    );
  }

  void _fillSchoolInfoForMonth(
      excel.Sheet sheet, List<Map<String, dynamic>> classResults) {
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(selectedYear ?? '');
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Tháng");
    sheet.cell(excel.CellIndex.indexByString("B2")).value =
        excel.TextCellValue(selectedMonth ?? '');
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B3")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    int totalMistakeCount = classResults.fold(
        0, (sum, result) => sum + result['totalMistakeCount'] as int);
    Map<String, int> totalConductCounts = {
      'Tốt': classResults.fold(
          0, (sum, result) => sum + (result['conductCounts']['Tốt'] as int)),
      'Khá': classResults.fold(
          0, (sum, result) => sum + (result['conductCounts']['Khá'] as int)),
      'Đạt': classResults.fold(
          0, (sum, result) => sum + (result['conductCounts']['Đạt'] as int)),
      'Chưa Đạt': classResults.fold(0,
          (sum, result) => sum + (result['conductCounts']['Chưa Đạt'] as int)),
    };

    sheet.cell(excel.CellIndex.indexByString("A5")).value =
        excel.TextCellValue("Tổng số lượng vi phạm toàn trường");
    sheet.cell(excel.CellIndex.indexByString("B5")).value =
        excel.TextCellValue(totalMistakeCount.toString());
    sheet.cell(excel.CellIndex.indexByString("A6")).value =
        excel.TextCellValue("Số lượng hạnh kiểm toàn trường");
    sheet.cell(excel.CellIndex.indexByString("B6")).value =
        excel.TextCellValue("Hạnh kiểm Tốt");
    sheet.cell(excel.CellIndex.indexByString("C6")).value =
        excel.TextCellValue("Hạnh kiểm Khá");
    sheet.cell(excel.CellIndex.indexByString("D6")).value =
        excel.TextCellValue("Hạnh kiểm Đạt");
    sheet.cell(excel.CellIndex.indexByString("E6")).value =
        excel.TextCellValue("Hạnh kiểm Chưa Đạt");
    sheet.cell(excel.CellIndex.indexByString("B7")).value =
        excel.TextCellValue(totalConductCounts['Tốt'].toString());
    sheet.cell(excel.CellIndex.indexByString("C7")).value =
        excel.TextCellValue(totalConductCounts['Khá'].toString());
    sheet.cell(excel.CellIndex.indexByString("D7")).value =
        excel.TextCellValue(totalConductCounts['Đạt'].toString());
    sheet.cell(excel.CellIndex.indexByString("E7")).value =
        excel.TextCellValue(totalConductCounts['Chưa Đạt'].toString());

    const int titleRow = 9;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
        excel.TextCellValue("BÁO CÁO TỔNG KẾT THÁNG VI PHẠM HỌC SINH");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
        excel.CellIndex.indexByString("J$titleRow"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
  }

  Future<void> _fillSchoolTableForMonth(
      excel.Sheet sheet, List<Map<String, dynamic>> classResults) async {
    const int headerRowIndex = 10;
    const headers = [
      "STT",
      "Mã lớp",
      "Tên lớp",
      "Niên khóa",
      "GVCN",
      "Số lượng vi phạm",
      "Số lượng HK Tốt",
      "Số lượng HK Khá",
      "Số lượng HK Đạt",
      "Số lượng HK Chưa Đạt",
    ];

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

    int currentRow = headerRowIndex + 1;
    int stt = 1;
    for (var result in classResults) {
      final rowData = [
        (stt++).toString(),
        result['classId'],
        result['className'],
        result['year'],
        result['teacherName'],
        result['totalMistakeCount'].toString(),
        result['conductCounts']['Tốt'].toString(),
        result['conductCounts']['Khá'].toString(),
        result['conductCounts']['Đạt'].toString(),
        result['conductCounts']['Chưa Đạt'].toString(),
      ];

      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(rowData[col]);
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  Future<Map<String, dynamic>> _fetchClassDataForSchoolMonth(
    String classId,
    Map<String, dynamic> classData,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
    List<Map<String, dynamic>> allMistakeDataByStudentList,
    String selectedMonth,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (School Month): $classId');

    int totalMistakeCount = 0;
    Map<String, int> conductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (School Month): $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final conductData = allConductDataByStudent[studentDetailId];
      if (conductData != null) {
        final monthData = conductData['_month']
                ['month${selectedMonth.replaceAll('Tháng ', '')}']
            as List<dynamic>?;
        if (monthData != null && monthData.length >= 2) {
          String conduct = monthData[1].toString();
          conductCounts[conduct] = (conductCounts[conduct] ?? 0) + 1;
          debugPrint('Hạnh kiểm cho $studentDetailId: $conduct');
        }
      }

      final mistakes = allMistakeDataByStudentList
          .where((mistake) =>
              mistake['STD_id'] == studentDetailId &&
              mistake['_month'] ==
                  'Tháng ${selectedMonth.replaceAll('Tháng ', '')}')
          .toList();
      totalMistakeCount += mistakes.length;
      debugPrint(
          'Số lượng vi phạm cho $studentDetailId: ${mistakes.length}, Chi tiết: $mistakes');
    }

    final result = {
      'classId': classId,
      'className': classData['_className'] ?? '',
      'year': classData['_year'] ?? '',
      'teacherName': classData['T_name'] ?? '',
      'totalMistakeCount': totalMistakeCount,
      'conductCounts': conductCounts,
    };
    debugPrint('Kết quả xử lý cho $classId (School Month): $result');

    return result;
  }

  Future<void> _createSheetForSchool(excel.Excel excelFile,
      BuildContext context, PeriodTypes periodType) async {
    String periodLabel;
    switch (periodType) {
      case PeriodTypes.semester1:
        periodLabel = "Học kỳ 1";
        break;
      case PeriodTypes.semester2:
        periodLabel = "Học kỳ 2";
        break;
      case PeriodTypes.fullYear:
        periodLabel = "Cả Năm";
        break;
    }

    debugPrint(
        'Bắt đầu tạo sheet cho $periodLabel (School) với selectedYear: $selectedYear');

    Query<Map<String, dynamic>> classQuery = FirebaseFirestore.instance
        .collection('CLASS')
        .where('_year', isEqualTo: selectedYear);

    final classSnapshot = await classQuery.get();
    final classDocs = classSnapshot.docs;
    final classIds = classDocs.map((doc) => doc.id).toList();
    debugPrint('Danh sách classIds: $classIds');

    if (classIds.isEmpty) {
      debugPrint('Không tìm thấy lớp nào phù hợp');
      return;
    }

    final studentDetailSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', whereIn: classIds)
        .get();
    final studentDetailMap = {
      for (var doc in studentDetailSnapshot.docs) doc.id: doc.data()
    };
    final allStudentDetailIds = studentDetailMap.keys.toList();
    debugPrint('Danh sách studentDetailIds: $allStudentDetailIds');

    final allConductSnapshot =
        await _batchQuery('CONDUCT_MONTH', 'STDL_id', allStudentDetailIds);
    final allConductDataByStudent = {
      for (var doc in allConductSnapshot) doc['STDL_id'] as String: doc
    };
    debugPrint('Dữ liệu CONDUCT_MONTH: $allConductDataByStudent');

    final futures = classIds.map((classId) async {
      final classDoc = classDocs.firstWhere((doc) => doc.id == classId).data();

      switch (periodType) {
        case PeriodTypes.semester1:
          return _fetchClassDataForSchoolSemester1(
              classId, classDoc, studentDetailMap, allConductDataByStudent);
        case PeriodTypes.semester2:
          return _fetchClassDataForSchoolSemester2(
              classId, classDoc, studentDetailMap, allConductDataByStudent);
        case PeriodTypes.fullYear:
          return _fetchClassDataForSchoolSemester3(
              classId, classDoc, studentDetailMap, allConductDataByStudent);
      }
    }).toList();

    final results = await Future.wait(futures);
    debugPrint(
        'Kết quả xử lý dữ liệu cho toàn trường ($periodLabel): $results');

    // Ghi đè lên sheet mặc định
    final defaultSheetName = excelFile.getDefaultSheet()!;
    final sheet = excelFile[defaultSheetName];

    switch (periodType) {
      case PeriodTypes.semester1:
        _fillSchoolInfoForSemester(sheet, 'Học kỳ 1');

        await _fillSchoolTableForSemester1(sheet, results);
        break;
      case PeriodTypes.semester2:
        _fillSchoolInfoForSemester(sheet, 'Học kỳ 2');
        await _fillSchoolTableForSemester2(sheet, results);
        break;
      case PeriodTypes.fullYear:
        _fillSchoolInfoForSemester(sheet, 'Cả năm');
        await _fillSchoolTableForSemester3(sheet, results);
        break;
    }

    // Lưu file Excel
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final fileName = _getFileName();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(excelFile.encode()!);
    debugPrint(
        'File Excel duy nhất cho School ($periodLabel) đã được lưu tại: $path');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File đã được lưu tại: $path')),
    );
  }

  Future<void> _createSheetForSchoolSemester1(
      excel.Excel excelFile, BuildContext context) async {
    debugPrint(
        'Bắt đầu tạo sheet cho Học kỳ 1 (School) với selectedYear: $selectedYear');

    Query<Map<String, dynamic>> classQuery = FirebaseFirestore.instance
        .collection('CLASS')
        .where('_year', isEqualTo: selectedYear);

    final classSnapshot = await classQuery.get();
    final classDocs = classSnapshot.docs;
    final classIds = classDocs.map((doc) => doc.id).toList();
    debugPrint('Danh sách classIds: $classIds');

    if (classIds.isEmpty) {
      debugPrint('Không tìm thấy lớp nào phù hợp');
      return;
    }

    final studentDetailSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', whereIn: classIds)
        .get();
    final studentDetailMap = {
      for (var doc in studentDetailSnapshot.docs) doc.id: doc.data()
    };
    final allStudentDetailIds = studentDetailMap.keys.toList();
    debugPrint('Danh sách studentDetailIds: $allStudentDetailIds');

    final allConductSnapshot =
        await _batchQuery('CONDUCT_MONTH', 'STDL_id', allStudentDetailIds);
    final allConductDataByStudent = {
      for (var doc in allConductSnapshot) doc['STDL_id'] as String: doc
    };
    debugPrint('Dữ liệu CONDUCT_MONTH: $allConductDataByStudent');

    final futures = classIds.map((classId) async {
      return _fetchClassDataForSchoolSemester1(
        classId,
        classDocs.firstWhere((doc) => doc.id == classId).data(),
        studentDetailMap,
        allConductDataByStudent,
      );
    }).toList();

    final results = await Future.wait(futures);
    debugPrint('Kết quả xử lý dữ liệu cho toàn trường (Học kỳ 1): $results');

    // Ghi đè lên sheet mặc định
    final defaultSheetName = excelFile.getDefaultSheet()!;
    final sheet = excelFile[defaultSheetName];
    _fillSchoolInfoForSemester1(sheet);
    await _fillSchoolTableForSemester1(sheet, results);

    // Lưu file Excel
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final fileName = _getFileName();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(excelFile.encode()!);
    debugPrint('File Excel duy nhất cho School (hk) đã được lưu tại: $path');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File đã được lưu tại: $path')),
    );
  }

  Future<Map<String, dynamic>> _fetchClassDataForSchoolSemester1(
    String classId,
    Map<String, dynamic> classData,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (School Semester 1): $classId');

    Map<String, Map<String, int>> monthlyConductCounts = {
      '9': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '10': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '11': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '12': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
    };
    Map<String, int> semesterConductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (School Semester 1): $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;
      final conductData = allConductDataByStudent[studentDetailId];

      String semesterConduct = studentDetail['_conductTerm1'];
      semesterConductCounts[semesterConduct] =
          (semesterConductCounts[semesterConduct] ?? 0) + 1;
      if (conductData != null) {
        for (var month in ['9', '10', '11', '12']) {
          final monthData =
              conductData['_month']['month$month'] as List<dynamic>?;
          if (monthData != null && monthData.length >= 2) {
            String conduct = monthData[1].toString();
            monthlyConductCounts[month]![conduct] =
                (monthlyConductCounts[month]![conduct] ?? 0) + 1;
          }
        }
      }
    }

    return {
      'classId': classId,
      'className': classData['_className'] ?? '',
      'year': classData['_year'] ?? '',
      'teacherName': classData['T_name'] ?? '',
      'monthlyConductCounts': monthlyConductCounts,
      'semesterConductCounts': semesterConductCounts,
    };
  }

  void _fillSchoolInfoForSemester1(excel.Sheet sheet) {
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(selectedYear ?? '');
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Học kỳ");
    sheet.cell(excel.CellIndex.indexByString("B2")).value =
        excel.TextCellValue("Học kỳ 1");
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B3")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    const int titleRow = 5;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
        excel.TextCellValue("BÁO CÁO TỔNG KẾT CHI TIẾT HỌC KỲ 1");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
        excel.CellIndex.indexByString("J$titleRow"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
  }

  Future<void> _fillSchoolTableForSemester1(
      excel.Sheet sheet, List<Map<String, dynamic>> classResults) async {
    const int headerRowIndex = 6;
    const headers = [
      "STT",
      "Mã lớp",
      "Tên lớp",
      "Niên khóa",
      "GVCN",
      "Tháng 9\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 10\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 11\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 12\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "HKI\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
    ];

    for (int col = 0; col < headers.length; col++) {
      final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
          excel.TextCellValue(headers[col]);
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
        textWrapping: excel.TextWrapping.WrapText,
      );
    }

    int currentRow = headerRowIndex + 1;
    int stt = 1;
    for (var result in classResults) {
      final monthlyCounts =
          result['monthlyConductCounts'] as Map<String, Map<String, int>>;
      final semesterCounts =
          result['semesterConductCounts'] as Map<String, int>;

      final rowData = [
        (stt++).toString(),
        result['classId'],
        result['className'],
        result['year'],
        result['teacherName'],
        "${monthlyCounts['9']!['Tốt']} - ${monthlyCounts['9']!['Khá']} - ${monthlyCounts['9']!['Đạt']} - ${monthlyCounts['9']!['Chưa Đạt']}",
        "${monthlyCounts['10']!['Tốt']} - ${monthlyCounts['10']!['Khá']} - ${monthlyCounts['10']!['Đạt']} - ${monthlyCounts['10']!['Chưa Đạt']}",
        "${monthlyCounts['11']!['Tốt']} - ${monthlyCounts['11']!['Khá']} - ${monthlyCounts['11']!['Đạt']} - ${monthlyCounts['11']!['Chưa Đạt']}",
        "${monthlyCounts['12']!['Tốt']} - ${monthlyCounts['12']!['Khá']} - ${monthlyCounts['12']!['Đạt']} - ${monthlyCounts['12']!['Chưa Đạt']}",
        "${semesterCounts['Tốt']} - ${semesterCounts['Khá']} - ${semesterCounts['Đạt']} - ${semesterCounts['Chưa Đạt']}",
      ];

      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(rowData[col]);
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  void _fillSchoolInfoForSemester(excel.Sheet sheet, String hocky) {
    sheet.cell(excel.CellIndex.indexByString("A1")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("B1")).value =
        excel.TextCellValue(selectedYear ?? '');
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Học kỳ");
    sheet.cell(excel.CellIndex.indexByString("B2")).value =
        excel.TextCellValue(hocky);
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("B3")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    const int titleRow = 5;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
        excel.TextCellValue("BÁO CÁO TỔNG KẾT CHI TIẾT HỌC KỲ 1");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
        excel.CellIndex.indexByString("J$titleRow"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
  }

  Future<Map<String, dynamic>> _fetchClassDataForSchoolSemester2(
    String classId,
    Map<String, dynamic> classData,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (School Semester 2): $classId');

    Map<String, Map<String, int>> monthlyConductCounts = {
      '1': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '2': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '3': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '4': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
      '5': {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0},
    };
    Map<String, int> semesterConductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (School Semester 2): $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;
      final conductData = allConductDataByStudent[studentDetailId];

      String semesterConduct = studentDetail['_conductTerm2'];
      semesterConductCounts[semesterConduct] =
          (semesterConductCounts[semesterConduct] ?? 0) + 1;
      if (conductData != null) {
        for (var month in ['1', '2', '3', '4', '5']) {
          final monthData =
              conductData['_month']['month$month'] as List<dynamic>?;
          if (monthData != null && monthData.length >= 2) {
            String conduct = monthData[1].toString();
            monthlyConductCounts[month]![conduct] =
                (monthlyConductCounts[month]![conduct] ?? 0) + 1;
          }
        }
      }
    }

    return {
      'classId': classId,
      'className': classData['_className'] ?? '',
      'year': classData['_year'] ?? '',
      'teacherName': classData['T_name'] ?? '',
      'monthlyConductCounts': monthlyConductCounts,
      'semesterConductCounts': semesterConductCounts,
    };
  }

  Future<void> _fillSchoolTableForSemester2(
      excel.Sheet sheet, List<Map<String, dynamic>> classResults) async {
    const int headerRowIndex = 6;
    const headers = [
      "STT",
      "Mã lớp",
      "Tên lớp",
      "Niên khóa",
      "GVCN",
      "Tháng 1\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 2\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 3\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 4\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Tháng 5\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "HKII\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
    ];

    for (int col = 0; col < headers.length; col++) {
      final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
          excel.TextCellValue(headers[col]);
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
        textWrapping: excel.TextWrapping.WrapText,
      );
    }

    int currentRow = headerRowIndex + 1;
    int stt = 1;
    for (var result in classResults) {
      final monthlyCounts =
          result['monthlyConductCounts'] as Map<String, Map<String, int>>;
      final semesterCounts =
          result['semesterConductCounts'] as Map<String, int>;

      final rowData = [
        (stt++).toString(),
        result['classId'],
        result['className'],
        result['year'],
        result['teacherName'],
        "${monthlyCounts['1']!['Tốt']} - ${monthlyCounts['1']!['Khá']} - ${monthlyCounts['1']!['Đạt']} - ${monthlyCounts['1']!['Chưa Đạt']}",
        "${monthlyCounts['2']!['Tốt']} - ${monthlyCounts['2']!['Khá']} - ${monthlyCounts['2']!['Đạt']} - ${monthlyCounts['2']!['Chưa Đạt']}",
        "${monthlyCounts['3']!['Tốt']} - ${monthlyCounts['3']!['Khá']} - ${monthlyCounts['3']!['Đạt']} - ${monthlyCounts['3']!['Chưa Đạt']}",
        "${monthlyCounts['4']!['Tốt']} - ${monthlyCounts['4']!['Khá']} - ${monthlyCounts['4']!['Đạt']} - ${monthlyCounts['4']!['Chưa Đạt']}",
        "${monthlyCounts['5']!['Tốt']} - ${monthlyCounts['5']!['Khá']} - ${monthlyCounts['5']!['Đạt']} - ${monthlyCounts['5']!['Chưa Đạt']}",
        "${semesterCounts['Tốt']} - ${semesterCounts['Khá']} - ${semesterCounts['Đạt']} - ${semesterCounts['Chưa Đạt']}",
      ];

      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(rowData[col]);
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  Future<Map<String, dynamic>> _fetchClassDataForSchoolSemester3(
    String classId,
    Map<String, dynamic> classData,
    Map<String, Map<String, dynamic>> studentDetailMap,
    Map<String, Map<String, dynamic>> allConductDataByStudent,
  ) async {
    debugPrint('Xử lý dữ liệu cho classId (): $classId');

    Map<String, int> semesterConductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };
    Map<String, int> semesterConductCounts1 = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };
    Map<String, int> semesterConductCounts2 = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0,
    };

    final studentDetailIdsForClass = studentDetailMap.keys
        .where((id) => studentDetailMap[id]!['Class_id'] == classId)
        .toList();
    debugPrint(
        'studentDetailIdsForClass (School Semester 2): $studentDetailIdsForClass');

    for (var studentDetailId in studentDetailIdsForClass) {
      final studentDetail = studentDetailMap[studentDetailId]!;

      String semesterConduct2 = studentDetail['_conductTerm2'];
      semesterConductCounts2[semesterConduct2] =
          (semesterConductCounts2[semesterConduct2] ?? 0) + 1;

      String semesterConduct1 = studentDetail['_conductTerm1'];
      semesterConductCounts1[semesterConduct1] =
          (semesterConductCounts1[semesterConduct1] ?? 0) + 1;

      String semesterConduct = studentDetail['_conductAllYear'];
      semesterConductCounts[semesterConduct] =
          (semesterConductCounts[semesterConduct] ?? 0) + 1;
    }

    return {
      'classId': classId,
      'className': classData['_className'] ?? '',
      'year': classData['_year'] ?? '',
      'teacherName': classData['T_name'] ?? '',
      'semesterConductCounts': semesterConductCounts,
      'semesterConductCounts1': semesterConductCounts1,
      'semesterConductCounts2': semesterConductCounts2,
    };
  }

  Future<void> _fillSchoolTableForSemester3(
      excel.Sheet sheet, List<Map<String, dynamic>> classResults) async {
    const int headerRowIndex = 6;
    const headers = [
      "STT",
      "Mã lớp",
      "Tên lớp",
      "Niên khóa",
      "GVCN",
      "Kết quả HK1\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Kết quả HK2\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
      "Kết quả Cả năm\nSố lượng HK\nTốt - Khá - Đạt - C.Đ",
    ];

    for (int col = 0; col < headers.length; col++) {
      final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
          excel.TextCellValue(headers[col]);
      sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
        textWrapping: excel.TextWrapping.WrapText,
      );
    }

    int currentRow = headerRowIndex + 1;
    int stt = 1;
    for (var result in classResults) {
      final semesterCounts =
          result['semesterConductCounts'] as Map<String, int>;
      final semesterCounts1 =
          result['semesterConductCounts1'] as Map<String, int>;
      final semesterCounts2 =
          result['semesterConductCounts2'] as Map<String, int>;

      final rowData = [
        (stt++).toString(),
        result['classId'],
        result['className'],
        result['year'],
        result['teacherName'],
        "${semesterCounts1['Tốt']} - ${semesterCounts1['Khá']} - ${semesterCounts1['Đạt']} - ${semesterCounts1['Chưa Đạt']}",
        "${semesterCounts2['Tốt']} - ${semesterCounts2['Khá']} - ${semesterCounts2['Đạt']} - ${semesterCounts2['Chưa Đạt']}",
        "${semesterCounts['Tốt']} - ${semesterCounts['Khá']} - ${semesterCounts['Đạt']} - ${semesterCounts['Chưa Đạt']}",
      ];

      for (int col = 0; col < rowData.length; col++) {
        final cellAddress = "${getColumnLetter(col)}$currentRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(rowData[col]);
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Left,
          textWrapping: excel.TextWrapping.WrapText,
        );
      }
      currentRow++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final year = Provider.of<YearProvider>(context).years;
    final classs = Provider.of<ClassProvider>(context).classNames;
    if (!classs.contains('Tất cả')) {
      classs.add('Tất cả');
    }
    final account = Provider.of<AccountProvider>(context).account;
    final idclass = Provider.of<TeacherProvider>(context).classIdTeacher;

    String yearc = '';
    String namec = '';

    if (idclass.length >= 9) {
      yearc = idclass.substring(idclass.length - 9);
      namec = idclass.substring(0, idclass.length - 9).toUpperCase();
    }

    // Set default values if account.goupID == 'giaoVien'
    if (account!.goupID == 'giaoVien') {
      selectedClass = namec;
      selectedYear = yearc;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      title: Center(
        child: Text(
          'Xuất Báo Cáo ${widget.reportType == 'class' ? 'Lớp Học' : 'Trường Học'}',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E88E5),
          ),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chọn lớp (ẩn nếu reportType == 'school')
              if (widget.reportType != 'school')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Chọn lớp',
                    labelStyle: const TextStyle(color: Color(0xFF78909C)),
                    fillColor: const Color(0xFFF1F5F9),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF1E88E5), width: 2),
                    ),
                  ),
                  items: classs
                      .map((className) => DropdownMenuItem(
                            value: className,
                            child: Text(className),
                          ))
                      .toList(),
                  value: selectedClass,
                  onChanged: account.goupID == 'giaoVien'
                      ? null
                      : (value) => setState(() {
                            selectedClass = value;
                            errorMessage = null;
                          }),
                ),
              const SizedBox(height: 16),
              // Chọn năm học
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Chọn năm học',
                  labelStyle: const TextStyle(color: Color(0xFF78909C)),
                  fillColor: const Color(0xFFF1F5F9),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF1E88E5), width: 2),
                  ),
                ),
                items: year
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        ))
                    .toList(),
                value: selectedYear,
                onChanged: account.goupID == 'giaoVien'
                    ? null
                    : (value) => setState(() {
                          selectedYear = value;
                          errorMessage = null;
                        }),
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Loại báo cáo', context),
              _buildSelectionCard(
                context,
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Tháng'),
                            value: 'Tháng',
                            groupValue: selectedOption,
                            onChanged: (value) => setState(() {
                              selectedOption = value;
                              selectedMonth = null;
                              selectedSemester = null;
                              errorMessage = null;
                            }),
                            activeColor: const Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Học kỳ'),
                            value: 'Học kỳ',
                            groupValue: selectedOption,
                            onChanged: (value) => setState(() {
                              selectedOption = value;
                              selectedMonth = null;
                              selectedSemester = null;
                              errorMessage = null;
                            }),
                            activeColor: const Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (selectedOption == 'Tháng') ...[
                _buildSectionHeader('Chọn tháng', context),
                _buildSelectionCard(
                  context,
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Tháng',
                      labelStyle: const TextStyle(color: Color(0xFF78909C)),
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF1E88E5), width: 2),
                      ),
                    ),
                    items: List.generate(12, (i) => 'Tháng ${i + 1}')
                        .map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            ))
                        .toList(),
                    value: selectedMonth,
                    onChanged: (value) => setState(() {
                      selectedMonth = value;
                      errorMessage = null;
                    }),
                  ),
                ),
              ],
              if (selectedOption == 'Học kỳ') ...[
                _buildSectionHeader('Chọn học kỳ', context),
                _buildSelectionCard(
                  context,
                  Column(
                    children: ['Học kỳ 1', 'Học kỳ 2', 'Cả Năm']
                        .map((semester) => RadioListTile<String>(
                              title: Text(semester),
                              value: semester,
                              groupValue: selectedSemester,
                              onChanged: (value) => setState(() {
                                selectedSemester = value;
                                errorMessage = null;
                              }),
                              activeColor: const Color(0xFF1E88E5),
                            ))
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              _buildExportSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF455A64),
            ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _buildExportSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin xuất file',
            style: textTheme.titleSmall?.copyWith(
              color: const Color(0xFF78909C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            canExport ? 'Tên file:' : 'Trạng thái:',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF455A64),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            canExport ? _getFileName() : 'Vui lòng chọn đầy đủ thông tin',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  canExport ? const Color(0xFF263238) : const Color(0xFF78909C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Định dạng: .xlsx',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF78909C),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.download_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
              label: const Text('Xuất File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canExport && !isExporting
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFFB0BEC5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              onPressed: canExport && !isExporting
                  ? () => exportToExcel(context)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    final date = DateTime.now();
    String prefix =
        widget.reportType == 'class' ? 'BaoCao_LopHoc' : 'BaoCao_TruongHoc';
    if (selectedOption == 'Tháng') {
      return '$prefix${selectedClass ?? 'TatCa'}_${selectedMonth ?? 'ChuaChon'}_${date.year}.xlsx';
    }
    return '$prefix${selectedClass ?? 'TatCa'}_${selectedSemester ?? 'ChuaChon'}_${date.year}.xlsx';
  }
}
