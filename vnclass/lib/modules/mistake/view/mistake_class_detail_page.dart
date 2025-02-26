import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/widget/item_class_mistake_student.dart';

class MistakeClassDetailPage extends StatefulWidget {
  const MistakeClassDetailPage({super.key});
  static const String routeName = '/mistake_class_detail_page';

  @override
  State<MistakeClassDetailPage> createState() => _MistakeClassDetailPageState();
}

class _MistakeClassDetailPageState extends State<MistakeClassDetailPage> {
  late Future<List<StudentDetailModel>> futureMistakeClass;
  ClassMistakeModel? classMistakeModel;
  String? selectedMonth;
  String? hocKy;
  bool _isInitialized = false;
  List<StudentDetailModel>? cachedData; // Cache dữ liệu cục bộ

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      classMistakeModel = arguments['classMistakeModel'];
      hocKy = arguments['hocKy'];

      final List<String> monthList = getThangList(hocKy ?? '');
      final String currentMonth = 'Tháng ${DateTime.now().month}';
      selectedMonth =
          monthList.contains(currentMonth) ? currentMonth : monthList.first;

      if (classMistakeModel != null) {
        futureMistakeClass = fetchMistakeClasses();
        _isInitialized = true;
      }
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

    // Cập nhật cache sau khi fetch thành công
    setState(() {
      cachedData = data;
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
    setState(() {
      futureMistakeClass = fetchMistakeClasses();
    });
    await futureMistakeClass; // Đợi fetch hoàn tất
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Cập nhật vi phạm lớp ${classMistakeModel?.className ?? ""}',
      implementLeading: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            DropMenuWidget<String>(
              hintText: 'Chọn tháng',
              items: getThangList(hocKy ?? ''),
              selectedItem: selectedMonth,
              onChanged: (newValue) {
                if (newValue != null && newValue != selectedMonth) {
                  setState(() {
                    selectedMonth = newValue;
                    futureMistakeClass = fetchMistakeClasses();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(fontSize: 18, color: Color(0xFF2F4F4F)),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                hintStyle: const TextStyle(
                    color: Color(0xFF696969),
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.search_outlined,
                      color: Color(0xFF1E90FF), size: 24),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFD3D3D3), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFF1E90FF), width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildHeaderText('Mã HS')),
                  Expanded(flex: 5, child: _buildHeaderText('Họ và Tên')),
                  Expanded(flex: 1, child: _buildHeaderText('Lần VP')),
                  Expanded(flex: 1, child: _buildHeaderText('Xem')),
                  Expanded(flex: 1, child: _buildHeaderText('Sửa')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: FutureBuilder<List<StudentDetailModel>>(
                  future: futureMistakeClass,
                  builder: (context, snapshot) {
                    // Hiển thị dữ liệu cache nếu có trong khi chờ fetch mới
                    final displayData =
                        snapshot.connectionState == ConnectionState.waiting &&
                                cachedData != null
                            ? cachedData
                            : snapshot.data;

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        cachedData == null) {
                      return _buildLoadingSkeleton();
                    }
                    if (snapshot.hasError) {
                      return _buildErrorWidget(snapshot.error.toString());
                    }
                    if (displayData == null || displayData.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: displayData.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return ItemClassMistakeStudent(
                          studentDetailModel: displayData[index],
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
    );
  }

  Widget _buildHeaderText(String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 36),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
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
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
