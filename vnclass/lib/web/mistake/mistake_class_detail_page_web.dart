import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/providers/class_mistake_provider.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/web/sidebar_widget.dart';

class MistakeClassDetailPageWeb extends StatefulWidget {
  const MistakeClassDetailPageWeb({super.key});
  static const String routeName = '/mistake_class_detail_page_web';

  @override
  State<MistakeClassDetailPageWeb> createState() =>
      _MistakeClassDetailPageWebState();
}

class _MistakeClassDetailPageWebState extends State<MistakeClassDetailPageWeb> {
  final Map<String, dynamic> menuItem = {
    'icon': Icons.warning,
    'label': 'Cập nhật vi phạm'
  }; // Chỉ 1 mục

  final bool _isSelected = true; // Mục được chọn sẵn

  late Future<List<StudentDetailModel>> futureMistakeClass;
  ClassMistakeModel? classMistakeModel;
  String? selectedMonth;
  String? hocKy;
  bool _isInitialized = false;
  List<StudentDetailModel>? cachedData;
  final TextEditingController _searchController = TextEditingController();
  List<StudentDetailModel>? filteredData;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    futureMistakeClass = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider =
          Provider.of<ClassMistakeProvider>(context, listen: false);
      final Map<String, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      classMistakeModel =
          arguments?['classMistakeModel'] ?? provider.classMistakeModel;
      hocKy = arguments?['hocKy'] ?? provider.hocKy;

      if (classMistakeModel == null || hocKy == null) {
        setState(() {
          _hasError = true;
        });
      } else {
        provider.setClassMistake(classMistakeModel!, hocKy!);

        final List<String> monthList = getThangList(hocKy ?? '');
        final String currentMonth = 'Tháng ${DateTime.now().month}';
        selectedMonth =
            monthList.contains(currentMonth) ? currentMonth : monthList.first;

        setState(() {
          futureMistakeClass = fetchMistakeClasses();
        });
      }
      _isInitialized = true;
    }
  }

  Future<List<StudentDetailModel>> fetchMistakeClasses() async {
    if (classMistakeModel == null || selectedMonth == null) return [];

    String monthToSearch = selectedMonth!.replaceFirst('Tháng ', '');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', isEqualTo: classMistakeModel!.idClass)
        .get();

    final data = await Future.wait(
      snapshot.docs
          .map((doc) => StudentDetailModel.fromFirestore(doc, monthToSearch)),
    );

    setState(() {
      cachedData = data;
      filteredData = data;
    });
    return data;
  }

  List<String> getThangList(String hocKy) {
    switch (hocKy) {
      case 'Học kỳ 1':
        return ['Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
      case 'Học kỳ 2':
        return ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5'];
      case 'Cả năm':
        return [
          'Tháng 1',
          'Tháng 2',
          'Tháng 3',
          'Tháng 4',
          'Tháng 5',
          'Tháng 9',
          'Tháng 10',
          'Tháng 11',
          'Tháng 12'
        ];
      default:
        return [];
    }
  }

  Future<void> _refreshData() async {
    if (classMistakeModel == null || selectedMonth == null) {
      _navigateBackWithMessage('Dữ liệu không hợp lệ. Vui lòng chọn lại lớp!');
      return;
    }

    setState(() {
      futureMistakeClass = fetchMistakeClasses();
    });
    await futureMistakeClass;
  }

  void _filterStudents(String query) {
    if (cachedData == null) return;
    setState(() {
      filteredData = cachedData!
          .where((student) =>
              student.nameStudent.toLowerCase().contains(query.toLowerCase()) ||
              student.idStudent.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateBackWithMessage(String message) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/mistake_main_page');
    }
  }

  void _onItemTapped() {
    // Không làm gì vì chỉ có 1 mục và đã chọn sẵn
    print('Đã nhấn: ${menuItem['label']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          SidebarWidget(
            appTitle: 'Ứng dụng của tôi',
            menuItem: menuItem, // Truyền 1 phần tử duy nhất
            isSelected: _isSelected, // Chọn sẵn
            onItemTap: _onItemTapped,
          ),
          Expanded(
            child: SingleChildScrollView(
              // Thêm cuộn ngang để tránh overflow
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width -
                    250, // Giới hạn chiều rộng
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E3A8A).withOpacity(0.9),
                            const Color(0xFF3B82F6).withOpacity(0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => _navigateBackWithMessage(
                                'Quay lại trang trước'),
                          ),
                          Expanded(
                            child: Text(
                              'Cập nhật vi phạm lớp ${classMistakeModel?.className ?? ""}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Tháng',
                                      labelStyle: const TextStyle(
                                          color: Color(0xFF1E3A8A)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD3D3D3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD3D3D3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1E90FF), width: 2),
                                      ),
                                    ),
                                    value: selectedMonth,
                                    items: getThangList(hocKy ?? '')
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null &&
                                          newValue != selectedMonth) {
                                        setState(() {
                                          selectedMonth = newValue;
                                          futureMistakeClass =
                                              fetchMistakeClasses();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterStudents,
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF2F4F4F)),
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm...',
                                      hintStyle: const TextStyle(
                                          color: Color(0xFF696969),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(Icons.search,
                                            color: Color(0xFF1E90FF), size: 24),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 16),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD3D3D3),
                                            width: 1.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1E90FF),
                                            width: 2.0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: _buildHeaderText('Mã HS')),
                                          Expanded(
                                              flex: 2,
                                              child: _buildHeaderText(
                                                  'Họ và Tên')),
                                          Expanded(
                                              flex: 1,
                                              child:
                                                  _buildHeaderText('Lần VP')),
                                          Expanded(
                                              flex: 1,
                                              child: _buildHeaderText('Xem')),
                                          Expanded(
                                              flex: 1,
                                              child: _buildHeaderText('Sửa')),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: RefreshIndicator(
                                        onRefresh: _refreshData,
                                        child: FutureBuilder<
                                            List<StudentDetailModel>>(
                                          future: futureMistakeClass,
                                          builder: (context, snapshot) {
                                            final displayData = snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting &&
                                                    cachedData != null
                                                ? filteredData ?? cachedData
                                                : filteredData ?? snapshot.data;

                                            if (_hasError) {
                                              return _buildErrorWidget(
                                                  'Dữ liệu không hợp lệ. Vui lòng chọn lại lớp!');
                                            }
                                            if (snapshot.connectionState ==
                                                    ConnectionState.waiting &&
                                                cachedData == null) {
                                              return _buildLoadingSkeleton();
                                            }
                                            if (snapshot.hasError) {
                                              return _buildErrorWidget(
                                                  snapshot.error.toString());
                                            }
                                            if (displayData == null ||
                                                displayData.isEmpty) {
                                              return const Center(
                                                  child:
                                                      Text('Không có dữ liệu'));
                                            }
                                            return ListView.separated(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              itemCount: displayData.length,
                                              separatorBuilder:
                                                  (context, index) => Divider(
                                                      height: 1,
                                                      color:
                                                          Colors.grey.shade200),
                                              itemBuilder: (context, index) {
                                                return _buildStudentRow(
                                                  context,
                                                  studentDetailModel:
                                                      displayData[index],
                                                  month: selectedMonth,
                                                  onRefresh: _refreshData,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildStudentRow(
    BuildContext context, {
    required StudentDetailModel studentDetailModel,
    String? month,
    required Future<void> Function() onRefresh,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  studentDetailModel.idStudent,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  studentDetailModel.nameStudent,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    studentDetailModel.numberOfErrors,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(FontAwesomeIcons.eye,
                        size: 18, color: Color(0xFF0288D1)),
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/mistake_view_mistake_page_web',
                      arguments: {
                        'studentDetailModel': studentDetailModel,
                        'month': month,
                      },
                    );
                    await onRefresh();
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(FontAwesomeIcons.pen,
                        size: 18, color: Color(0xFF2E7D32)),
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/mistake_type_mistake_page_web',
                      arguments: studentDetailModel,
                    );
                    await onRefresh();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 2,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 1,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 1,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 1,
                child: Container(height: 20, color: Colors.grey.shade200)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Lỗi: $error', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _navigateBackWithMessage('Quay lại trang trước'),
            child: const Text('Quay lại',
                style: TextStyle(color: Color(0xFF1E3A8A))),
          ),
        ],
      ),
    );
  }
}
