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

    return Future.wait(snapshot.docs
        .map((doc) => StudentDetailModel.fromFirestore(doc, monthToSearch)));
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

  void _refreshData() {
    setState(() {
      futureMistakeClass = fetchMistakeClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Cập nhật vi phạm lớp ${classMistakeModel?.className ?? ""}',
      implementLeading: true,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm học sinh...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 100),
                      child: Text(
                        'Mã HS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(
                        'Họ và Tên',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(
                        'Lần VP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 36),
                      child: Text(
                        'Xem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 36),
                      child: Text(
                        'Sửa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 6),
            Expanded(
              child: FutureBuilder<List<StudentDetailModel>>(
                future: futureMistakeClass,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      return ItemClassMistakeStudent(
                        studentDetailModel: snapshot.data![index],
                        month: selectedMonth,
                        onRefresh: _refreshData,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
