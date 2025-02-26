import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DialogReport extends StatefulWidget {
  final String reportType;

  const DialogReport({super.key, required this.reportType});

  @override
  _DialogReport createState() => _DialogReport();
}

class _DialogReport extends State<DialogReport> {
  String? selectedOption;
  String? selectedMonth;
  String? selectedSemester;
  String? selectedClass;
  String? selectedYear;
  bool isExporting = false;
  String? errorMessage;

  bool get canExport =>
      selectedClass != null &&
      selectedYear != null &&
      selectedOption != null &&
      (selectedOption == 'Tháng'
          ? selectedMonth != null
          : selectedSemester != null);

  Future<void> exportToExcel(BuildContext context) async {
    if (!canExport) return;

    setState(() {
      isExporting = true;
      errorMessage = null;
    });

    try {
      QuerySnapshot snapshot;
      if (widget.reportType == 'class' && selectedClass != null) {
        snapshot = await FirebaseFirestore.instance
            .collection('STUDENT_DETAIL')
            .where('Class_id', isEqualTo: selectedClass?.replaceAll('Lớp ', ''))
            .get();
      } else {
        snapshot =
            await FirebaseFirestore.instance.collection('STUDENT_DETAIL').get();
      }
      List<Map<String, dynamic>> data = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile[excelFile.getDefaultSheet()!];

      sheet.cell(excel.CellIndex.indexByString("A1")).value = excel.TextCellValue(
          "Báo cáo: ${widget.reportType == 'class' ? 'Vi phạm lớp học' : 'Vi phạm trường học'}");
      sheet.cell(excel.CellIndex.indexByString("A2")).value =
          excel.TextCellValue("Lớp: $selectedClass");
      sheet.cell(excel.CellIndex.indexByString("A3")).value =
          excel.TextCellValue("Năm học: $selectedYear");
      sheet.cell(excel.CellIndex.indexByString("A4")).value = excel.TextCellValue(
          "Thời gian: ${selectedOption == 'Tháng' ? selectedMonth : selectedSemester}");

      int headerRow = 6;
      List<String> headers = [
        "STT",
        "Mã học sinh",
        "Họ và tên",
        "Số lượng vi phạm"
      ];
      for (int col = 0; col < headers.length; col++) {
        String cellAddress = "${String.fromCharCode(65 + col)}$headerRow";
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
            excel.TextCellValue(headers[col]);
        sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
            excel.CellStyle(bold: true);
      }

      int currentRow = headerRow + 1;
      for (int i = 0; i < data.length; i++) {
        var item = data[i];
        sheet.cell(excel.CellIndex.indexByString("A$currentRow")).value =
            excel.TextCellValue((i + 1).toString());
        sheet.cell(excel.CellIndex.indexByString("B$currentRow")).value =
            excel.TextCellValue(item['idStudent'] ?? '');
        sheet.cell(excel.CellIndex.indexByString("C$currentRow")).value =
            excel.TextCellValue(item['nameStudent'] ?? '');
        sheet.cell(excel.CellIndex.indexByString("D$currentRow")).value =
            excel.TextCellValue(item['numberOfErrors'] ?? '0');
        currentRow++;
      }

      Directory? downloadsDir = await getExternalStorageDirectory();
      String path =
          '${downloadsDir?.path ?? '/storage/emulated/0/Download'}/report_${widget.reportType}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      File file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(excelFile.encode()!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Xuất file thành công!'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isExporting = false;
        errorMessage = 'Lỗi khi xuất file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
              Row(
                children: [
                  Expanded(
                    child: DropMenuWidget<String>(
                      hintText: 'Chọn lớp',
                      items: ['Lớp 10', 'Lớp 11', 'Lớp 12'],
                      selectedItem: selectedClass,
                      onChanged: (value) => setState(() {
                        selectedClass = value;
                        errorMessage = null;
                      }),
                      fillColor: const Color(0xFFF1F5F9),
                      borderColor: const Color(0xFFB0BEC5),
                      textStyle: textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF263238)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropMenuWidget<String>(
                      hintText: 'Chọn năm học',
                      items: ['2023-2024', '2022-2023', '2021-2022'],
                      selectedItem: selectedYear,
                      onChanged: (value) => setState(() {
                        selectedYear = value;
                        errorMessage = null;
                      }),
                      fillColor: const Color(0xFFF1F5F9),
                      borderColor: const Color(0xFFB0BEC5),
                      textStyle: textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF263238)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Loại báo cáo', context),
              _buildSelectionCard(
                context,
                RadioButtonWidget(
                  options: const ['Tháng', 'Học kỳ'],
                  onChanged: (value) => setState(() {
                    selectedOption = value;
                    selectedMonth = null;
                    selectedSemester = null;
                    errorMessage = null;
                  }),
                  layout: RadioLayout.horizontal,
                  activeColor: const Color(0xFF1E88E5),
                  labelStyle: textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF263238)),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedOption == 'Tháng') ...[
                _buildSectionHeader('Chọn tháng', context),
                _buildSelectionCard(
                  context,
                  DropMenuWidget(
                    hintText: 'Tháng',
                    items: List.generate(12, (i) => 'Tháng ${i + 1}'),
                    onChanged: (value) => setState(() {
                      selectedMonth = value;
                      errorMessage = null;
                    }),
                    fillColor: const Color(0xFFF1F5F9),
                    borderColor: const Color(0xFFB0BEC5),
                    textStyle: textTheme.bodyMedium
                        ?.copyWith(color: const Color(0xFF263238)),
                  ),
                ),
              ],
              if (selectedOption == 'Học kỳ') ...[
                _buildSectionHeader('Chọn học kỳ', context),
                _buildSelectionCard(
                  context,
                  RadioButtonWidget(
                    options: const ['Học kỳ 1', 'Học kỳ 2', 'Cả Năm'],
                    onChanged: (value) => setState(() {
                      selectedSemester = value;
                      errorMessage = null;
                    }),
                    layout: RadioLayout.vertical,
                    activeColor: const Color(0xFF1E88E5),
                    labelStyle: textTheme.bodyMedium
                        ?.copyWith(color: const Color(0xFF263238)),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
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
            style: textTheme.labelLarge?.copyWith(
              color: const Color(0xFFD32F2F), // Đỏ
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
    final colors = theme.colorScheme;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin xuất file',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF78909C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          canExport
                              ? _getFileName()
                              : 'Vui lòng chọn thông tin',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: canExport
                                ? const Color(0xFF263238)
                                : const Color(0xFF78909C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Định dạng: .xlsx',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF78909C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            size: 20,
                            color: Color(0xFFE3F2FD), // Xanh dương nhạt
                          ),
                    label: const Text('Xuất File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canExport && !isExporting
                          ? const Color(0xFF1E88E5)
                          : const Color(0xFFB0BEC5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: canExport && !isExporting
                        ? () => exportToExcel(context)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
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
