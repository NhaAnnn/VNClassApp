// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:excel/excel.dart' as excel;
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:vnclass/common/widget/drop_menu_widget.dart';
// import 'package:vnclass/common/widget/radio_button_widget.dart';
// import 'package:vnclass/modules/main_home/controller/class_provider.dart';
// import 'package:vnclass/modules/main_home/controller/year_provider.dart';
// import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';

// class DialogExportAcc extends StatefulWidget {
//   const DialogExportAcc({super.key});

//   @override
//   State<DialogExportAcc> createState() => _DialogExportAccState();
// }

// class _DialogExportAccState extends State<DialogExportAcc> {
//   String? selectedOption;
//   bool isExporting = false;
//   String? selectedYear;
//   String? selectedClass;
//   List<String>? classes = []; // Ví dụ
//   List<String>? years = []; // Ví dụ
//   @override
//   Widget build(BuildContext context) {
//     final yearsProvider = Provider.of<YearProvider>(context);
//     final classesProvider = Provider.of<ClassProvider>(context);
//     final years =
//         List<String>.from(yearsProvider.years); // Tạo bản sao của danh sách
//     final classes = List<String>.from(
//         classesProvider.classNames); // Tạo bản sao của danh sách

//     // Kiểm tra và chỉ thêm "Tất cả" nếu chưa tồn tại
//     if (!classes.contains('Tất cả')) {
//       classes.add('Tất cả');
//     }

//     // return AlertDialog(
//     //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     //   backgroundColor: Colors.white,
//     //   elevation: 6,
//     //   title: Container(
//     //     padding: const EdgeInsets.symmetric(vertical: 12),
//     //     decoration: BoxDecoration(
//     //       gradient: LinearGradient(
//     //         colors: [Colors.blueAccent, Colors.blue.shade700],
//     //         begin: Alignment.topLeft,
//     //         end: Alignment.bottomRight,
//     //       ),
//     //       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//     //     ),
//     //     child: const Text(
//     //       'Xuất Báo Cáo',
//     //       style: TextStyle(
//     //         fontWeight: FontWeight.bold,
//     //         fontSize: 20,
//     //         color: Colors.white,
//     //         fontFamily: 'Roboto',
//     //       ),
//     //       textAlign: TextAlign.center,
//     //     ),
//     //   ),
//     //   contentPadding:
//     //       const EdgeInsets.all(8), // Giảm padding mặc định của content
//     //   content: SingleChildScrollView(
//     //     child: Column(
//     //       mainAxisSize: MainAxisSize.min,
//     //       crossAxisAlignment: CrossAxisAlignment.stretch,
//     //       children: [
//     //         _buildAccountSelectionCard(),
//     //         if (selectedOption == 'Học sinh - PHHS') ...[
//     //           const SizedBox(height: 10),
//     //           _buildClassSelectionCard(classes, years),
//     //         ],
//     //         const SizedBox(height: 10),
//     //         _buildExportActionCard(),
//     //       ],
//     //     ),
//     //   ),
//     //   actions: [
//     //     Padding(
//     //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     //       child: Row(
//     //         children: [
//     //           Expanded(child: _buildDownloadButton()),
//     //           const SizedBox(width: 8),
//     //           Expanded(child: _buildCancelButton()),
//     //         ],
//     //       ),
//     //     ),
//     //   ],
//     // );

//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: Colors.white,
//       elevation: 6,
//       contentPadding: const EdgeInsets.all(0), // Loại bỏ padding mặc định
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.85, // Tăng chiều ngang
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Tiêu đề với gradient
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.blueAccent, Colors.blue.shade700],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: const Center(
//                 child: Text(
//                   'Xuất Báo Cáo',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                     color: Colors.white,
//                     fontFamily: 'Roboto',
//                   ),
//                 ),
//               ),
//             ),
//             // Nội dung chính
//             SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16), // Padding đều xung quanh
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildAccountSelectionCard(),
//                     if (selectedOption == 'Học sinh - PHHS') ...[
//                       const SizedBox(height: 16),
//                       _buildClassSelectionCard(classes, years),
//                     ],
//                     const SizedBox(height: 16),
//                     _buildExportActionCard(),
//                   ],
//                 ),
//               ),
//             ),
//             // Nút hành động
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Row(
//                 children: [
//                   Expanded(child: _buildDownloadButton()),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildCancelButton()),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildAccountSelectionCard() {
//   //   return Card(
//   //     elevation: 3,
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(8),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           const Text(
//   //             'Chọn loại tài khoản',
//   //             style: TextStyle(
//   //               fontWeight: FontWeight.w600,
//   //               fontSize: 16,
//   //               color: Colors.black87,
//   //               fontFamily: 'Roboto',
//   //             ),
//   //           ),
//   //           const SizedBox(height: 6),
//   //           Column(
//   //             children: [
//   //               for (var option in const [
//   //                 'Học sinh - PHHS',
//   //                 'Giáo viên',
//   //                 'Ban giám hiệu'
//   //               ])
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.start,
//   //                   children: [
//   //                     Radio<String>(
//   //                       value: option,
//   //                       groupValue: selectedOption,
//   //                       onChanged: (value) {
//   //                         setState(() {
//   //                           selectedOption = value;
//   //                           selectedYear = null;
//   //                           selectedClass = null;
//   //                         });
//   //                       },
//   //                     ),
//   //                     Text(
//   //                       option,
//   //                       style:
//   //                           const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
//   //                     ),
//   //                   ],
//   //                 ),
//   //             ],
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildClassSelectionCard(List<String> classes, List<String> years) {
//   //   return Card(
//   //     elevation: 3,
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(8),
//   //       child: Column(
//   //         children: [
//   //           DropMenuWidget(
//   //             items: years,
//   //             hintText: 'Chọn năm học',
//   //             selectedItem: selectedYear,
//   //             onChanged: (newValue) => setState(() => selectedYear = newValue!),
//   //           ),
//   //           const SizedBox(height: 8),
//   //           DropMenuWidget(
//   //             items: classes,
//   //             hintText: 'Chọn lớp',
//   //             selectedItem: selectedClass,
//   //             onChanged: (newValue) =>
//   //                 setState(() => selectedClass = newValue!),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildExportActionCard() {
//   //   return Card(
//   //     elevation: 3,
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //     color: Colors.blue.shade50,
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(8),
//   //       child: Row(
//   //         children: [
//   //           Expanded(
//   //             flex: 2,
//   //             child: Text(
//   //               'Dữ liệu xuất: ${selectedOption == 'Học sinh - PHHS' ? 'Báo cáo thông tin học sinh' : 'Báo cáo thông tin nhân sự'}',
//   //               style: const TextStyle(
//   //                 fontSize: 14,
//   //                 fontWeight: FontWeight.w500,
//   //                 color: Colors.blueGrey,
//   //                 fontFamily: 'Roboto',
//   //               ),
//   //             ),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           ElevatedButton(
//   //             onPressed: isExporting
//   //                 ? null
//   //                 : () async {
//   //                     setState(() => isExporting = true);
//   //                     await exportToExcel(context);
//   //                     setState(() => isExporting = false);
//   //                   },
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Colors.blueAccent,
//   //               shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(8)),
//   //               padding:
//   //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//   //             ),
//   //             child: isExporting
//   //                 ? const SizedBox(
//   //                     width: 16,
//   //                     height: 16,
//   //                     child: CircularProgressIndicator(
//   //                       color: Colors.white,
//   //                       strokeWidth: 2,
//   //                     ),
//   //                   )
//   //                 : const Text(
//   //                     'Xuất file',
//   //                     style: TextStyle(
//   //                       color: Colors.white,
//   //                       fontWeight: FontWeight.bold,
//   //                       fontSize: 13,
//   //                       fontFamily: 'Roboto',
//   //                     ),
//   //                   ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildDownloadButton() {
//   //   return ElevatedButton.icon(
//   //     onPressed: isExporting
//   //         ? null
//   //         : () async {
//   //             setState(() => isExporting = true);
//   //             await exportToExcel(context);
//   //             setState(() => isExporting = false);
//   //           },
//   //     icon: const Icon(Icons.download, color: Colors.white, size: 18),
//   //     label: const Text(
//   //       'Tải xuống',
//   //       style: TextStyle(
//   //         color: Colors.white,
//   //         fontWeight: FontWeight.bold,
//   //         fontSize: 13,
//   //         fontFamily: 'Roboto',
//   //       ),
//   //     ),
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: Colors.green,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//   //     ),
//   //   );
//   // }

//   // Widget _buildCancelButton() {
//   //   return ElevatedButton.icon(
//   //     onPressed: isExporting ? null : () => Navigator.of(context).pop(),
//   //     icon: const Icon(Icons.close, color: Colors.white, size: 18),
//   //     label: const Text(
//   //       'Thoát',
//   //       style: TextStyle(
//   //         color: Colors.white,
//   //         fontWeight: FontWeight.bold,
//   //         fontSize: 13,
//   //         fontFamily: 'Roboto',
//   //       ),
//   //     ),
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: Colors.redAccent,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//   //     ),
//   //   );
//   // }
//   Widget _buildAccountSelectionCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Chọn loại tài khoản',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//                 color: Colors.black87,
//                 fontFamily: 'Roboto',
//               ),
//             ),
//             const SizedBox(height: 12),
//             Column(
//               children: [
//                 for (var option in const [
//                   'Học sinh - PHHS',
//                   'Giáo viên',
//                   'Ban giám hiệu'
//                 ])
//                   RadioListTile<String>(
//                     value: option,
//                     groupValue: selectedOption,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedOption = value;
//                         selectedYear = null;
//                         selectedClass = null;
//                       });
//                     },
//                     title: Text(
//                       option,
//                       style:
//                           const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 0),
//                     dense: true,
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildClassSelectionCard(List<String> classes, List<String> years) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             DropMenuWidget(
//               items: years,
//               hintText: 'Chọn năm học',
//               selectedItem: selectedYear,
//               onChanged: (newValue) => setState(() => selectedYear = newValue!),
//             ),
//             const SizedBox(height: 12),
//             DropMenuWidget(
//               items: classes,
//               hintText: 'Chọn lớp',
//               selectedItem: selectedClass,
//               onChanged: (newValue) =>
//                   setState(() => selectedClass = newValue!),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExportActionCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.blue.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 3,
//               child: Text(
//                 'Dữ liệu xuất: ${selectedOption == 'Học sinh - PHHS' ? 'Báo cáo thông tin học sinh' : 'Báo cáo thông tin nhân sự'}',
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.blueGrey,
//                   fontFamily: 'Roboto',
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: isExporting
//                   ? null
//                   : () async {
//                       setState(() => isExporting = true);
//                       await exportToExcel(context);
//                       setState(() => isExporting = false);
//                       if (context.mounted) {
//                         Navigator.pop(context); // Đóng dialog sau khi xuất xong
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//               child: isExporting
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Text(
//                       'Xuất file',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         fontFamily: 'Roboto',
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDownloadButton() {
//     return ElevatedButton.icon(
//       onPressed: isExporting
//           ? null
//           : () async {
//               setState(() => isExporting = true);
//               await exportToExcel(context);
//               setState(() => isExporting = false);
//               if (context.mounted) {
//                 Navigator.pop(context); // Đóng dialog sau khi xuất xong
//               }
//             },
//       icon: const Icon(Icons.download, color: Colors.white, size: 20),
//       label: const Text(
//         'Tải xuống',
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//           fontFamily: 'Roboto',
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.green,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//     );
//   }

//   Widget _buildCancelButton() {
//     return ElevatedButton.icon(
//       onPressed: isExporting ? null : () => Navigator.of(context).pop(),
//       icon: const Icon(Icons.close, color: Colors.white, size: 20),
//       label: const Text(
//         'Thoát',
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//           fontFamily: 'Roboto',
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.redAccent,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//     );
//   }

//   String getColumnLetter(int colIndex) {
//     return String.fromCharCode(65 + colIndex);
//   }

//   Future<void> exportToExcel(BuildContext context) async {
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       if (androidInfo.version.sdkInt >= 33) {
//         await _handleAndroid13Permissions(context);
//       } else {
//         await _handleLegacyAndroidPermissions(context);
//       }
//     }

//     var excelFile = excel.Excel.createExcel();
//     await _createSheetsByClassId(excelFile);
//   }

//   Future<void> _handleAndroid13Permissions(BuildContext context) async {
//     final status = await Permission.photos.status;
//     if (!status.isGranted) {
//       final result = await Permission.photos.request();
//       if (result.isDenied || result.isPermanentlyDenied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Vui lòng cấp quyền để lưu file')),
//         );
//         if (result.isPermanentlyDenied) await openAppSettings();
//       }
//     }
//   }

//   Future<void> _handleLegacyAndroidPermissions(BuildContext context) async {
//     final status = await Permission.storage.status;
//     if (!status.isGranted) {
//       final result = await Permission.storage.request();
//       if (result.isDenied || result.isPermanentlyDenied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Vui lòng cấp quyền để lưu file')),
//         );
//         if (result.isPermanentlyDenied) await openAppSettings();
//       }
//     }
//   }

//   Future<List<Map<String, dynamic>>> _batchQuery(
//       String collection, String field, List<String> ids,
//       {String? whereClause, String? whereValue}) async {
//     const batchSize = 10;
//     List<QuerySnapshot<Map<String, dynamic>>> batches = [];

//     for (int i = 0; i < ids.length; i += batchSize) {
//       final batchIds = ids.sublist(
//           i, i + batchSize > ids.length ? ids.length : i + batchSize);
//       Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//           .collection(collection)
//           .where(field, whereIn: batchIds);
//       if (whereClause != null && whereValue != null) {
//         query = query.where(whereClause, isEqualTo: whereValue);
//       }
//       final snapshot = await query.get();
//       batches.add(snapshot);
//     }

//     return batches
//         .expand((batch) => batch.docs)
//         .map((doc) => doc.data())
//         .toList();
//   }

//   Future<void> _createSheetsByClassId(excel.Excel excelFile) async {
//     // Lấy dữ liệu tài khoản dựa vào selectedOption
//     final accountSnapshot = await FirebaseFirestore.instance
//         .collection('ACCOUNT')
//         .where('_groupID',
//             isEqualTo: selectedOption == 'Học sinh - PHHS'
//                 ? 'hocSinh'
//                 : selectedOption == 'Giáo viên'
//                     ? 'giaoVien'
//                     : 'banGH')
//         .get();

//     if (accountSnapshot.docs.isEmpty) return;

//     final accountMap = {
//       for (var doc in accountSnapshot.docs) doc['_id'] as String: doc.data()
//     };
//     final accIds = accountMap.keys.toList();

//     if (selectedOption == 'Học sinh - PHHS') {
//       // Logic cho học sinh
//       final studentDocs = await _batchQuery('STUDENT', 'ACC_id', accIds);
//       final studentMap = {
//         for (var doc in studentDocs) doc['_id'] as String: doc
//       };
//       final stIds = studentMap.keys.toList();

//       final studentDetailDocs =
//           await _batchQuery('STUDENT_DETAIL', 'ST_id', stIds);
//       final studentDetailMap = {
//         for (var doc in studentDetailDocs) doc['ST_id'] as String: doc
//       };

//       // Lọc lớp theo năm học và lớp được chọn
//       Query<Map<String, dynamic>> classQuery =
//           FirebaseFirestore.instance.collection('CLASS');

//       if (selectedYear != null && selectedClass == null) {
//         // Chỉ chọn năm học
//         classQuery = classQuery.where('_year', isEqualTo: selectedYear);
//       } else if (selectedYear != null &&
//           selectedClass != null &&
//           selectedClass != 'Tất cả') {
//         // Chọn cả năm và lớp cụ thể
//         classQuery = classQuery.where('_id',
//             isEqualTo:
//                 '${selectedClass.toString().toLowerCase()}${selectedYear.toString()}');
//       } else if (selectedYear != null && selectedClass == 'Tất cả') {
//         // Chọn năm và tất cả lớp
//         classQuery = classQuery.where('_year', isEqualTo: selectedYear);
//       }

//       final classDocs = await classQuery.get();
//       final classMap = {
//         for (var doc in classDocs.docs)
//           doc.id: ClassMistakeModel.fromFirestore(doc)
//       };
//       final classIds = classMap.keys.toList();

//       if (classIds.isEmpty) return;

//       // Xử lý song song dữ liệu cho từng lớp
//       final futures = classIds.map((classId) async {
//         return _fetchStudentDataOptimized(
//             classId, accountMap, studentMap, studentDetailMap);
//       }).toList();

//       final results = await Future.wait(futures);

//       // Tạo một file Excel duy nhất với nhiều sheet (mỗi lớp một sheet)
//       final defaultSheetName = excelFile.getDefaultSheet()!;
//       for (int i = 0; i < classIds.length; i++) {
//         final classId = classIds[i];
//         final sheetName = classId;

//         // Nếu là sheet đầu tiên, sử dụng sheet mặc định và đổi tên
//         if (i == 0) {
//           excelFile.rename(defaultSheetName, sheetName);
//           final sheet = excelFile[sheetName];
//           _fillClassInfo(sheet, classId, classMap[classId]);
//           await _fillStudentExcelTable(sheet, results[i], excelFile);
//         } else {
//           // Thêm sheet mới cho các lớp còn lại
//           final sheet = excelFile[sheetName];
//           _fillClassInfo(sheet, classId, classMap[classId]);
//           await _fillStudentExcelTable(sheet, results[i], excelFile);
//         }
//       }

//       // Lưu file duy nhất sau khi xử lý tất cả sheet
//       try {
//         final directory = Directory('/storage/emulated/0/Download');
//         final path =
//             '${directory.path}/st_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
//         final file = File(path);
//         await file.writeAsBytes(excelFile.encode()!);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('File đã được lưu tại: $path')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Lỗi khi xuất file: ${e.toString()}')),
//         );
//       }
//     } else {
//       // Logic cho Giáo viên/Ban giám hiệu (giữ nguyên không thay đổi)
//       final accountSnapshot = await FirebaseFirestore.instance
//           .collection('ACCOUNT')
//           .where('_groupID',
//               isEqualTo: selectedOption == 'Giáo viên' ? 'giaoVien' : 'banGH')
//           .get();

//       if (accountSnapshot.docs.isEmpty) return;

//       final accountMap = {
//         for (var doc in accountSnapshot.docs) doc['_id'] as String: doc.data()
//       };
//       final accIds = accountMap.keys.toList();

//       final teacherDocs = await _batchQuery(
//           selectedOption == 'Giáo viên' ? 'TEACHER' : 'TEACHER',
//           'ACC_id',
//           accIds);
//       final teacherMap = {
//         for (var doc in teacherDocs) doc['_id'] as String: doc
//       };

//       // Tạo một sheet duy nhất
//       final sheet = excelFile[excelFile.getDefaultSheet()!];
//       _fillStaffInfo(sheet);
//       await _fillStaffExcelTable(sheet, accountMap, teacherMap, excelFile);

//       // Lưu file cho Giáo viên/Ban giám hiệu
//       try {
//         final directory = Directory('/storage/emulated/0/Download');
//         final path =
//             '${directory.path}/nvxxreport_${DateTime.now().millisecondsSinceEpoch}.xlsx';
//         final file = File(path);
//         await file.writeAsBytes(excelFile.encode()!);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('File đã được lưu tại: $path')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Lỗi khi xuất file: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   void _fillClassInfo(
//       excel.Sheet sheet, String classId, ClassMistakeModel? classInfo) {
//     sheet.cell(excel.CellIndex.indexByString("A1")).value =
//         excel.TextCellValue("Tên lớp");
//     sheet.cell(excel.CellIndex.indexByString("C1")).value =
//         excel.TextCellValue(classInfo?.className ?? classId);
//     sheet.cell(excel.CellIndex.indexByString("A2")).value =
//         excel.TextCellValue("Niên khóa");
//     sheet.cell(excel.CellIndex.indexByString("C2")).value =
//         excel.TextCellValue(classInfo?.academicYear ?? selectedYear ?? '');
//     sheet.cell(excel.CellIndex.indexByString("A3")).value =
//         excel.TextCellValue("Giáo viên chủ nhiệm");
//     sheet.cell(excel.CellIndex.indexByString("C3")).value =
//         excel.TextCellValue(classInfo?.homeroomTeacher ?? '');
//     sheet.cell(excel.CellIndex.indexByString("A4")).value =
//         excel.TextCellValue("Ngày xuất báo cáo");
//     sheet.cell(excel.CellIndex.indexByString("C4")).value =
//         excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

//     // Định dạng tiêu đề
//     for (int row = 1; row <= 4; row++) {
//       sheet.cell(excel.CellIndex.indexByString("A$row")).cellStyle =
//           excel.CellStyle(
//         bold: true,
//         horizontalAlign: excel.HorizontalAlign.Left,
//       );
//       sheet.merge(excel.CellIndex.indexByString("A$row"),
//           excel.CellIndex.indexByString("B$row"));
//       sheet.cell(excel.CellIndex.indexByString("C$row")).cellStyle =
//           excel.CellStyle(
//         horizontalAlign: excel.HorizontalAlign.Left,
//       );
//     }

//     int titleRow = 5;
//     sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
//         excel.TextCellValue(
//             "DANH SÁCH TÀI KHOẢN HS - PHHS LỚP ${classInfo?.className.toUpperCase() ?? ''}");
//     sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
//         excel.CellIndex.indexByString("H$titleRow"));
//     sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
//         excel.CellStyle(
//       bold: true,
//       fontSize: 14,
//       horizontalAlign: excel.HorizontalAlign.Center,
//     );
//   }

//   Future<void> _fillStudentExcelTable(
//       excel.Sheet sheet, List<dynamic> data, excel.Excel excelFile) async {
//     const int headerRowIndex = 6;
//     const headers = [
//       "STT",
//       "Họ và tên",
//       "Ngày sinh",
//       "Giới tính",
//       "Tên tài khoản HS",
//       "Mật khẩu HS",
//       "Tên tài khoản PHHS",
//       "Mật khẩu PHHS",
//     ];

//     // Ghi header
//     for (int col = 0; col < headers.length; col++) {
//       final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
//       sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
//           excel.TextCellValue(headers[col]);
//       sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
//           excel.CellStyle(
//         bold: true,
//         horizontalAlign: excel.HorizontalAlign.Center,
//         textWrapping: excel.TextWrapping.WrapText,
//       );
//     }
//     // Thiết lập chiều cao tự động cho hàng chứa header
//     sheet.setRowHeight(headerRowIndex, 0);

//     // Ghi dữ liệu
//     int currentRow = headerRowIndex + 1;
//     for (var studentData in data) {
//       final account = studentData['account'];
//       final student = studentData['student'];
//       final detail = studentData['detail'];

//       sheet.cell(excel.CellIndex.indexByString("A$currentRow")).value =
//           excel.TextCellValue((currentRow - headerRowIndex).toString());
//       sheet.cell(excel.CellIndex.indexByString("B$currentRow")).value =
//           excel.TextCellValue(
//               detail['_studentName'] ?? account['_accName'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("C$currentRow")).value =
//           excel.TextCellValue(detail['_birthday'] ?? account['_birth'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("D$currentRow")).value =
//           excel.TextCellValue(detail['_gender'] ?? account['_gender'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("E$currentRow")).value =
//           excel.TextCellValue(account['_userName'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("F$currentRow")).value =
//           excel.TextCellValue(account['_password'] ?? '123');
//       // Giả sử PHHS có tài khoản riêng, cần lấy từ collection khác nếu có
//       sheet.cell(excel.CellIndex.indexByString("G$currentRow")).value =
//           excel.TextCellValue(student['P_id'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("H$currentRow")).value =
//           excel.TextCellValue(student['P_password'] ?? '123');

//       // Định dạng dữ liệu
//       for (int col = 0; col < headers.length; col++) {
//         final cellAddress = "${getColumnLetter(col)}$currentRow";
//         sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
//             excel.CellStyle(
//           horizontalAlign: excel.HorizontalAlign.Left,
//         );
//       }
//       currentRow++;
//     }
//   }

//   void _fillStaffInfo(excel.Sheet sheet) {
//     sheet.cell(excel.CellIndex.indexByString("A1")).value =
//         excel.TextCellValue("Ngày xuất báo cáo");
//     sheet.cell(excel.CellIndex.indexByString("B1")).value =
//         excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

//     sheet.cell(excel.CellIndex.indexByString("A1")).cellStyle = excel.CellStyle(
//       bold: true,
//       horizontalAlign: excel.HorizontalAlign.Left,
//     );
//     sheet.cell(excel.CellIndex.indexByString("B1")).cellStyle = excel.CellStyle(
//       horizontalAlign: excel.HorizontalAlign.Left,
//     );

//     sheet.cell(excel.CellIndex.indexByString("A3")).value =
//         excel.TextCellValue("DANH SÁCH TÀI KHOẢN GIÁO VIÊN ");
//     sheet.merge(excel.CellIndex.indexByString("A3"),
//         excel.CellIndex.indexByString("F3"));
//     sheet.cell(excel.CellIndex.indexByString("A3")).cellStyle = excel.CellStyle(
//       bold: true,
//       fontSize: 14,
//       horizontalAlign: excel.HorizontalAlign.Center,
//     );
//   }

//   Future<void> _fillStaffExcelTable(
//       excel.Sheet sheet,
//       Map<String, dynamic> accountMap,
//       Map<String, dynamic> staffMap,
//       excel.Excel excelFile) async {
//     const int headerRowIndex = 4;
//     const headers = [
//       "STT",
//       "Họ và tên",
//       "Ngày sinh",
//       "Giới tính",
//       "Tên đăng nhập",
//       "Mật khẩu",
//       // "Lớp phụ trách",
//     ];

//     // Ghi header
//     for (int col = 0; col < headers.length; col++) {
//       final cellAddress = "${getColumnLetter(col)}$headerRowIndex";
//       sheet.cell(excel.CellIndex.indexByString(cellAddress)).value =
//           excel.TextCellValue(headers[col]);
//       sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
//           excel.CellStyle(
//         bold: true,
//         horizontalAlign: excel.HorizontalAlign.Center,
//       );
//     }

//     // Ghi dữ liệu
//     int currentRow = headerRowIndex + 1;
//     int stt = 1;
//     for (var staffId in staffMap.keys) {
//       final staff = staffMap[staffId];
//       final account = accountMap[staff['ACC_id']];

//       sheet.cell(excel.CellIndex.indexByString("A$currentRow")).value =
//           excel.TextCellValue(stt.toString());
//       sheet.cell(excel.CellIndex.indexByString("B$currentRow")).value =
//           excel.TextCellValue(account['_accName'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("C$currentRow")).value =
//           excel.TextCellValue(account['_birth'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("D$currentRow")).value =
//           excel.TextCellValue(account['_gender'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("E$currentRow")).value =
//           excel.TextCellValue(account['_userName'] ?? '');
//       sheet.cell(excel.CellIndex.indexByString("F$currentRow")).value =
//           excel.TextCellValue(account['_password'] ?? '123');

//       // Định dạng dữ liệu
//       for (int col = 0; col < headers.length; col++) {
//         final cellAddress = "${getColumnLetter(col)}$currentRow";
//         sheet.cell(excel.CellIndex.indexByString(cellAddress)).cellStyle =
//             excel.CellStyle(
//           horizontalAlign: excel.HorizontalAlign.Left,
//         );
//       }
//       currentRow++;
//       stt++;
//     }
//   }

//   Future<List<dynamic>> _fetchStudentDataOptimized(
//       String classId,
//       Map<String, dynamic> accountMap,
//       Map<String, dynamic> studentMap,
//       Map<String, dynamic> studentDetailMap) async {
//     final result = [];
//     final studentsInClass = studentDetailMap.values
//         .where((detail) => detail['Class_id'] == classId);

//     for (var detail in studentsInClass) {
//       final student = studentMap[detail['ST_id']];
//       final account = accountMap[student['ACC_id']];
//       result.add({
//         'account': account,
//         'student': student,
//         'detail': detail,
//       });
//     }
//     return result;
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';

class DialogExportAcc extends StatefulWidget {
  const DialogExportAcc({super.key});

  @override
  State<DialogExportAcc> createState() => _DialogExportAccState();
}

class _DialogExportAccState extends State<DialogExportAcc> {
  String? selectedOption; // Mặc định là null
  bool isExporting = false;
  String? selectedYear;
  String? selectedClass;

  @override
  Widget build(BuildContext context) {
    final yearsProvider = Provider.of<YearProvider>(context);
    final classesProvider = Provider.of<ClassProvider>(context);
    final years = List<String>.from(yearsProvider.years);
    final classes = List<String>.from(classesProvider.classNames);

    if (!classes.contains('Tất cả')) {
      classes.add('Tất cả');
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 6,
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Text(
                  'Xuất Báo Cáo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAccountSelectionCard(),
                      if (selectedOption == 'Học sinh - PHHS') ...[
                        const SizedBox(height: 16),
                        _buildClassSelectionCard(classes, years),
                      ],
                      const SizedBox(height: 16),
                      _buildExportActionCard(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(child: _buildDownloadButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCancelButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Column(
              children: [
                for (var option in const [
                  'Học sinh - PHHS',
                  'Giáo viên',
                  'Ban giám hiệu'
                ])
                  RadioListTile<String>(
                    value: option,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        selectedYear = null;
                        selectedClass = null;
                      });
                    },
                    title: Text(
                      option,
                      style:
                          const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    dense: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelectionCard(List<String> classes, List<String> years) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropMenuWidget(
              items: years,
              hintText: 'Chọn năm học',
              selectedItem: selectedYear,
              onChanged: (newValue) => setState(() => selectedYear = newValue!),
            ),
            const SizedBox(height: 12),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Dữ liệu xuất: ${selectedOption == 'Học sinh - PHHS' ? 'Báo cáo thông tin học sinh' : selectedOption != null ? 'Báo cáo thông tin nhân sự' : 'Chưa chọn loại tài khoản'}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ElevatedButton(
            //   onPressed: isExporting || selectedOption == null
            //       ? null // Vô hiệu hóa nút nếu chưa chọn loại tài khoản
            //       : () async {
            //           setState(() => isExporting = true);
            //           await exportToExcel(context);
            //           setState(() => isExporting = false);
            //           if (context.mounted) {
            //             Navigator.pop(context);
            //           }
            //         },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blueAccent,
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8)),
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //   ),
            //   child: isExporting
            //       ? const SizedBox(
            //           width: 20,
            //           height: 20,
            //           child: CircularProgressIndicator(
            //             color: Colors.white,
            //             strokeWidth: 2,
            //           ),
            //         )
            //       : const Text(
            //           'Xuất file',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 14,
            //             fontFamily: 'Roboto',
            //           ),
            //         ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return ElevatedButton.icon(
      onPressed: isExporting || selectedOption == null
          ? null // Vô hiệu hóa nút nếu chưa chọn loại tài khoản
          : () async {
              setState(() => isExporting = true);
              await exportToExcel(context);
              setState(() => isExporting = false);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
      icon: const Icon(Icons.download, color: Colors.white, size: 20),
      label: const Text(
        'Tải xuống',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton.icon(
      onPressed: isExporting ? null : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close, color: Colors.white, size: 20),
      label: const Text(
        'Thoát',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  String getColumnLetter(int colIndex) {
    return String.fromCharCode(65 + colIndex);
  }

  Future<void> exportToExcel(BuildContext context) async {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn loại tài khoản trước khi xuất file')),
      );
      return;
    }

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

      Query<Map<String, dynamic>> classQuery =
          FirebaseFirestore.instance.collection('CLASS');

      if (selectedYear != null && selectedClass == null) {
        classQuery = classQuery.where('_year', isEqualTo: selectedYear);
      } else if (selectedYear != null &&
          selectedClass != null &&
          selectedClass != 'Tất cả') {
        classQuery = classQuery.where('_id',
            isEqualTo:
                '${selectedClass.toString().toLowerCase()}${selectedYear.toString()}');
      } else if (selectedYear != null && selectedClass == 'Tất cả') {
        classQuery = classQuery.where('_year', isEqualTo: selectedYear);
      }

      final classDocs = await classQuery.get();
      final classMap = {
        for (var doc in classDocs.docs)
          doc.id: ClassMistakeModel.fromFirestore(doc)
      };
      final classIds = classMap.keys.toList();

      if (classIds.isEmpty) return;

      final futures = classIds.map((classId) async {
        return _fetchStudentDataOptimized(
            classId, accountMap, studentMap, studentDetailMap);
      }).toList();

      final results = await Future.wait(futures);

      final defaultSheetName = excelFile.getDefaultSheet()!;
      for (int i = 0; i < classIds.length; i++) {
        final classId = classIds[i];
        final sheetName = classId;

        if (i == 0) {
          excelFile.rename(defaultSheetName, sheetName);
          final sheet = excelFile[sheetName];
          _fillClassInfo(sheet, classId, classMap[classId]);
          await _fillStudentExcelTable(sheet, results[i], excelFile);
        } else {
          final sheet = excelFile[sheetName];
          _fillClassInfo(sheet, classId, classMap[classId]);
          await _fillStudentExcelTable(sheet, results[i], excelFile);
        }
      }

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

      final sheet = excelFile[excelFile.getDefaultSheet()!];
      _fillStaffInfo(sheet);
      await _fillStaffExcelTable(sheet, accountMap, teacherMap, excelFile);

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
    sheet.cell(excel.CellIndex.indexByString("C1")).value =
        excel.TextCellValue(classInfo?.className ?? classId);
    sheet.cell(excel.CellIndex.indexByString("A2")).value =
        excel.TextCellValue("Niên khóa");
    sheet.cell(excel.CellIndex.indexByString("C2")).value =
        excel.TextCellValue(classInfo?.academicYear ?? selectedYear ?? '');
    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("Giáo viên chủ nhiệm");
    sheet.cell(excel.CellIndex.indexByString("C3")).value =
        excel.TextCellValue(classInfo?.homeroomTeacher ?? '');
    sheet.cell(excel.CellIndex.indexByString("A4")).value =
        excel.TextCellValue("Ngày xuất báo cáo");
    sheet.cell(excel.CellIndex.indexByString("C4")).value =
        excel.TextCellValue(DateFormat('dd/MM/yyyy').format(DateTime.now()));

    for (int row = 1; row <= 4; row++) {
      sheet.cell(excel.CellIndex.indexByString("A$row")).cellStyle =
          excel.CellStyle(
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Left,
      );
      sheet.merge(excel.CellIndex.indexByString("A$row"),
          excel.CellIndex.indexByString("B$row"));
      sheet.cell(excel.CellIndex.indexByString("C$row")).cellStyle =
          excel.CellStyle(
        horizontalAlign: excel.HorizontalAlign.Left,
      );
    }

    int titleRow = 5;
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).value =
        excel.TextCellValue(
            "DANH SÁCH TÀI KHOẢN HS - PHHS LỚP ${classInfo?.className.toUpperCase() ?? ''}");
    sheet.merge(excel.CellIndex.indexByString("A$titleRow"),
        excel.CellIndex.indexByString("H$titleRow"));
    sheet.cell(excel.CellIndex.indexByString("A$titleRow")).cellStyle =
        excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
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
    sheet.setRowHeight(headerRowIndex, 0);

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
      sheet.cell(excel.CellIndex.indexByString("G$currentRow")).value =
          excel.TextCellValue(student['P_id'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("H$currentRow")).value =
          excel.TextCellValue(student['P_password'] ?? '123');

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

    sheet.cell(excel.CellIndex.indexByString("A3")).value =
        excel.TextCellValue("DANH SÁCH TÀI KHOẢN GIÁO VIÊN ");
    sheet.merge(excel.CellIndex.indexByString("A3"),
        excel.CellIndex.indexByString("F3"));
    sheet.cell(excel.CellIndex.indexByString("A3")).cellStyle = excel.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: excel.HorizontalAlign.Center,
    );
  }

  Future<void> _fillStaffExcelTable(
      excel.Sheet sheet,
      Map<String, dynamic> accountMap,
      Map<String, dynamic> staffMap,
      excel.Excel excelFile) async {
    const int headerRowIndex = 4;
    const headers = [
      "STT",
      "Họ và tên",
      "Ngày sinh",
      "Giới tính",
      "Tên đăng nhập",
      "Mật khẩu",
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
          excel.TextCellValue(account['_userName'] ?? '');
      sheet.cell(excel.CellIndex.indexByString("F$currentRow")).value =
          excel.TextCellValue(account['_password'] ?? '123');

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
}
