// import 'package:flutter/material.dart';
// import 'package:vnclass/common/widget/button_widget.dart';
// import 'package:vnclass/common/widget/drop_menu_widget.dart';
// import 'package:vnclass/common/widget/radio_button_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart'
//     as excel; // Use prefix to avoid ambiguous import
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class DialogReport extends StatefulWidget {
//   const DialogReport({super.key});

//   @override
//   _DialogReport createState() => _DialogReport();
// }

// class _DialogReport extends State<DialogReport> {
//   String? selectedOption;
//   String? selectedMonth;
//   String? selectedSemester;

//   Future<void> exportToExcel(BuildContext context) async {
//     // Fetch data from Firestore
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('PARENT').get();
//     List<Map<String, dynamic>> data =
//         snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//     print('Dữ liệu data: $data');

//     // Create a new Excel file
//     var excelFile = excel.Excel.createExcel();
//     var sheet = excelFile[excelFile.getDefaultSheet()!];

//     // Add column headers
//     sheet.appendRow([
//       excel.TextCellValue('Tên'),
//       excel.TextCellValue('Thông tin 1'),
//       excel.TextCellValue('Thông tin 2'),
//     ]);

//     // Add data to the file
//     for (var item in data) {
//       sheet.appendRow([
//         excel.TextCellValue(item['_id'] ?? ''),
//         excel.TextCellValue(item['info1'] ?? ''),
//         excel.TextCellValue(item['info2'] ?? ''),
//       ]);
//     }

//     // Save the Excel file to the Downloads folder
//     Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
//     String path = '${downloadsDirectory.path}/report.xlsx';
//     File file = File(path);
//     await file.create(recursive: true); // Tạo thư mục nếu chưa tồn tại
//     await file.writeAsBytes(excelFile.encode() ?? []);

//     // Notify the user
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text('File đã được tải về: $path')));
//   }

//   /// Hàm hỗ trợ chuyển chỉ số cột (0, 1, 2, …) thành ký tự (A, B, C, …)
//   String getColumnLetter(int colIndex) {
//     // Giả sử số cột nhỏ hơn 26 (Từ A đến Z)
//     return String.fromCharCode(65 + colIndex);
//   }
// // Future<void> exportToExcel13(BuildContext context) async {
// //     var excelFile = excel.Excel.createExcel();
// //     var sheet = excelFile[excelFile.getDefaultSheet()!];

// //     // PHẦN 1: THÔNG TIN LỚP HỌC
// //     sheet.cell(excel.CellIndex.indexByString("A1")).value =
// //         excel.TextCellValue("Tên lớp");
// //     sheet.cell(excel.CellIndex.indexByString("B1")).value =
// //         excel.TextCellValue("10A1");

// //     sheet.cell(excel.CellIndex.indexByString("A2")).value =
// //         excel.TextCellValue("Niên khóa");
// //     sheet.cell(excel.CellIndex.indexByString("B2")).value =
// //         excel.TextCellValue("2023-2024");

// //     sheet.cell(excel.CellIndex.indexByString("A3")).value =
// //         excel.TextCellValue("Giáo viên chủ nhiệm");
// //     sheet.cell(excel.CellIndex.indexByString("B3")).value =
// //         excel.TextCellValue("Nguyễn Thị Minh");

// //     sheet.cell(excel.CellIndex.indexByString("A4")).value =
// //         excel.TextCellValue("Tổng số lượng vi phạm");
// //     sheet.cell(excel.CellIndex.indexByString("B4")).value = excel.TextCellValue(
// //         "Tổng số lượng vi phạm"); // Số nguyên có thể giữ nguyên

// //     sheet.cell(excel.CellIndex.indexByString("A5")).value =
// //         excel.TextCellValue("Ngày xuất báo cáo");
// //     sheet.cell(excel.CellIndex.indexByString("B5")).value =
// //         excel.TextCellValue("Ngày xuất báo cáo");

// //     // PHẦN 2: TIÊU ĐỀ BÁO CÁO
// //     int titleRow = 7;
// //     sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
// //         excel.TextCellValue("BÁO CÁO TỔNG KẾT VI PHẠM HỌC SINH");
// //     sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
// //         excel.CellIndex.indexByString("I$titleRow"));

// //     var titleStyle = excel.CellStyle(
// //       bold: true,
// //       fontSize: 14,
// //       horizontalAlign: excel.HorizontalAlign.Center,
// //     );
// //     sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
// //         titleStyle;

// //     // PHẦN 3: BẢNG DỮ LIỆU HỌC SINH
// //     int headerRowIndex = 9;
// //     List<String> headers = [
// //       "STT",
// //       "Mã học sinh",
// //       "Họ và tên",
// //       "Ngày sinh",
// //       "Giới tính",
// //       "Hạnh kiểm",
// //       "Điểm rèn luyện",
// //       "Số lượng vi phạm",
// //       "Thông tin các lỗi vi phạm",
// //     ];

// //     // Thêm viền và autofit cho tiêu đề bảng
// //     for (int col = 0; col < headers.length; col++) {
// //       String cellAddress = "${getColumnLetter(col)}$headerRowIndex";
// //       var cell = sheet.cell(excel.CellIndex.indexByString(cellAddress));

// //       // Thêm viền
// //       cell.cellStyle = excel.CellStyle(
// //         bold: true,
// //         horizontalAlign: excel.HorizontalAlign.Center,
// //         border: excel.Border(
// //           left: excel.BorderStyle.Thin,
// //           right: excel.BorderStyle.Thin,
// //           top: excel.BorderStyle.Thin,
// //           bottom: excel.BorderStyle.Thin,
// //         ),
// //         textWrapping: excel.TextWrapping.WrapText, // Bật wrap text
// //       );
// //       cell.value = excel.TextCellValue(headers[col]);
// //     }

// // // Autofit chiều cao dòng tiêu đề
// //     sheet.rowAtIndex(headerRowIndex - 1).height =
// //         20.0; // Điều chỉnh giá trị theo nhu cầu

// // // Dữ liệu mẫu
// //     List<List<dynamic>> tableData = [/*...*/];

// //     int currentRow = headerRowIndex + 1;
// //     for (var rowData in tableData) {
// //       int maxLineCount = 1; // Đếm số dòng tối đa trong hàng

// //       for (int col = 0; col < rowData.length; col++) {
// //         String cellAddress = "${getColumnLetter(col)}$currentRow";
// //         dynamic value = rowData[col];

// //         // Xử lý giá trị
// //         if (value is String) {
// //           sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
// //               excel.TextCellValue(value);
// //           // Tính số dòng nếu có \n
// //           maxLineCount = max(maxLineCount, value.split('\n').length);
// //         } else {
// //           sheet.cell(excel.CellIndex.indexByString(cellAddress)).value = value;
// //         }

// //         // Thêm viền cho từng ô
// //         sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
// //             excel.CellStyle(
// //           horizontalAlign: excel.HorizontalAlign.Left,
// //           textWrapping: excel.TextWrapping.WrapText,
// //           border: excel.Border(
// //             left: excel.BorderStyle.Thin,
// //             right: excel.BorderStyle.Thin,
// //             top: excel.BorderStyle.Thin,
// //             bottom: excel.BorderStyle.Thin,
// //           ),
// //         );
// //       }

// //       // Autofit chiều cao dòng dựa trên số dòng
// //       sheet.rowAtIndex(currentRow - 1).height =
// //           maxLineCount * 15.0; // 15.0 là height mỗi dòng
// //       currentRow++;
// //     }

// //     // PHẦN LƯU FILE
// //     Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
// //     String path = '${downloadsDirectory.path}/report.xlsx';
// //     File file = File(path);
// //     await file.create(recursive: true);
// //     await file.writeAsBytes(excelFile.encode()!);

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('File đã được tải về: $path')),
// //     );
// //   }

//   Future<void> exportToExcel1(BuildContext context) async {
//     var excelFile = excel.Excel.createExcel();
//     var sheet = excelFile[excelFile.getDefaultSheet()!];

//     // PHẦN 1: THÔNG TIN LỚP HỌC
//     sheet.cell(excel.CellIndex.indexByString("A1")).value =
//         excel.TextCellValue("Tên lớp");
//     sheet.cell(excel.CellIndex.indexByString("B1")).value =
//         excel.TextCellValue("10A1");

//     sheet.cell(excel.CellIndex.indexByString("A2")).value =
//         excel.TextCellValue("Niên khóa");
//     sheet.cell(excel.CellIndex.indexByString("B2")).value =
//         excel.TextCellValue("2023-2024");

//     sheet.cell(excel.CellIndex.indexByString("A3")).value =
//         excel.TextCellValue("Giáo viên chủ nhiệm");
//     sheet.cell(excel.CellIndex.indexByString("B3")).value =
//         excel.TextCellValue("Nguyễn Thị Minh");

//     sheet.cell(excel.CellIndex.indexByString("A4")).value =
//         excel.TextCellValue("Tổng số lượng vi phạm");
//     sheet.cell(excel.CellIndex.indexByString("B4")).value = excel.TextCellValue(
//         "Tổng số lượng vi phạm"); // Số nguyên có thể giữ nguyên

//     sheet.cell(excel.CellIndex.indexByString("A5")).value =
//         excel.TextCellValue("Tháng");
//     sheet.cell(excel.CellIndex.indexByString("B5")).value =
//         excel.TextCellValue("Tháng");
//     sheet.cell(excel.CellIndex.indexByString("A6")).value =
//         excel.TextCellValue("Ngày xuất báo cáo");
//     sheet.cell(excel.CellIndex.indexByString("B6")).value =
//         excel.TextCellValue("Ngày xuất báo cáo");

//     // PHẦN 2: TIÊU ĐỀ BÁO CÁO
//     int titleRow = 7;
//     sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
//         excel.TextCellValue("BÁO CÁO TỔNG KẾT VI PHẠM HỌC SINH");
//     sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
//         excel.CellIndex.indexByString("I$titleRow"));

//     var titleStyle = excel.CellStyle(
//       bold: true,
//       fontSize: 14,
//       horizontalAlign: excel.HorizontalAlign.Center,
//     );
//     sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
//         titleStyle;

//     // PHẦN 3: BẢNG DỮ LIỆU HỌC SINH
//     int headerRowIndex = 9;
//     List<String> headers = [
//       "STT",
//       "Mã học sinh",
//       "Họ và tên",
//       "Ngày sinh",
//       "Giới tính",
//       "Hạnh kiểm",
//       "Điểm rèn luyện",
//       "Số lượng vi phạm",
//       "Thông tin các lỗi vi phạm",
//     ];

//     for (int col = 0; col < headers.length; col++) {
//       String cellAddress = "${getColumnLetter(col)}$headerRowIndex";
//       sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
//           excel.TextCellValue(headers[col]);
//       sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
//           excel.CellStyle(
//         bold: true,
//         horizontalAlign: excel.HorizontalAlign.Center,
//       );
//     }

//     // DỮ LIỆU MẪU
//     List<List<dynamic>> tableData = [/*...*/];

//     int currentRow = headerRowIndex + 1;
//     for (var rowData in tableData) {
//       for (int col = 0; col < rowData.length; col++) {
//         String cellAddress = "${getColumnLetter(col)}$currentRow";
//         dynamic value = rowData[col];

//         // Xử lý các kiểu dữ liệu khác nhau
//         if (value is String) {
//           sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
//               excel.TextCellValue(value);
//         } else {
//           sheet.cell(excel.CellIndex.indexByString(cellAddress)).value = value;
//         }

//         sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
//             excel.CellStyle(
//           horizontalAlign: excel.HorizontalAlign.Left,
//           textWrapping: excel.TextWrapping.WrapText, // Đổi thành textWrapping
//         );
//       }
//       currentRow++;
//     }

//     // PHẦN LƯU FILE
//     Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
//     String path = '${downloadsDirectory.path}/report.xlsx';
//     File file = File(path);
//     await file.create(recursive: true);
//     await file.writeAsBytes(excelFile.encode()!);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('File đã được tải về: $path')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         'Chọn Thông Tin',
//         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//       ),
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.8,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text('Xuất theo: ',
//                       style: TextStyle(fontWeight: FontWeight.w600)),
//                   Expanded(
//                     child: RadioButtonWidget(
//                       options: ['Tháng', 'Học kỳ'],
//                       onChanged: (value) {
//                         setState(() {
//                           selectedOption = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               if (selectedOption == 'Tháng') ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text('Chọn tháng',
//                         style: TextStyle(fontWeight: FontWeight.w600)),
//                     Expanded(
//                       child: DropMenuWidget(
//                         hintText: 'Tháng',
//                         items: [
//                           'Tháng 1',
//                           'Tháng 2',
//                           // Add more months as needed
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             selectedMonth = value;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//               ],
//               if (selectedOption == 'Học kỳ') ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text('Chọn học kỳ',
//                         style: TextStyle(fontWeight: FontWeight.w600)),
//                     Expanded(
//                       child: RadioButtonWidget(
//                         options: [
//                           'Học kỳ 1',
//                           'Học kỳ 2',
//                           'Cả Năm',
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             selectedSemester = value;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//               ],
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: Colors.red,
//                     width: 1,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(30),
//                       spreadRadius: 4,
//                       blurRadius: 7,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         flex: 6,
//                         child: Text(
//                           'xxx',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         flex: 4,
//                         child: ButtonWidget(
//                           title: 'Xuất file',
//                           ontap: () {
//                             exportToExcel(context);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('Đóng', style: TextStyle(color: Colors.red)),
//         ),
//       ],
//     );
//   }

// }
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DialogReport extends StatefulWidget {
  const DialogReport({super.key});

  @override
  _DialogReport createState() => _DialogReport();
}

class _DialogReport extends State<DialogReport> {
  String? selectedOption;
  String? selectedMonth;
  String? selectedSemester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: colors.surface,
      title: Center(
        child: Text(
          'Xuất Báo Cáo',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Loại báo cáo', context),
              _buildSelectionCard(
                context,
                RadioButtonWidget(
                  options: const ['Tháng', 'Học kỳ'],
                  onChanged: (value) => setState(() => selectedOption = value),
                  layout: RadioLayout.horizontal,
                  activeColor: colors.primary,
                  labelStyle: textTheme.bodyLarge,
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
                    onChanged: (value) => setState(() => selectedMonth = value),
                    fillColor: colors.surfaceContainerHighest,
                    borderColor: colors.outline,
                    textStyle: textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (selectedOption == 'Học kỳ') ...[
                _buildSectionHeader('Chọn học kỳ', context),
                _buildSelectionCard(
                  context,
                  RadioButtonWidget(
                    options: const ['Học kỳ 1', 'Học kỳ 2', 'Cả Năm'],
                    onChanged: (value) =>
                        setState(() => selectedSemester = value),
                    layout: RadioLayout.vertical,
                    activeColor: colors.primary,
                    labelStyle: textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              _buildExportSection(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 12),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ĐÓNG',
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(90)),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outline..withAlpha(80)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin xuất file:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface..withAlpha(20),
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
                          _getFileName(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Định dạng: .xlsx',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('Xuất File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => exportToExcel(context),
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
    if (selectedOption == 'Tháng') {
      return 'BaoCao_${selectedMonth ?? 'Chưa chọn tháng'}_${date.year}.xlsx';
    }
    return 'BaoCao_${selectedSemester ?? 'Chưa chọn học kỳ'}_${date.year}.xlsx';
  }

  // Giữ nguyên hàm exportToExcel
  void exportToExcel(BuildContext context) {
    // ... implementation ...
  }
}
