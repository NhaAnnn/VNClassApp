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
  bool _isInitialized = false; // Thêm biến cờ kiểm tra

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      classMistakeModel = arguments['classMistakeModel'];
      hocKy = arguments['hocKy'];

      // Lấy danh sách tháng dựa trên học kỳ
      final List<String> monthList = getThangList(hocKy ?? '');

      // Xác định tháng hiện tại
      final String currentMonth = 'Tháng ${DateTime.now().month}';

      // Logic chọn giá trị mặc định
      if (monthList.isNotEmpty) {
        selectedMonth =
            monthList.contains(currentMonth) ? currentMonth : monthList.first;
      } else {
        selectedMonth = null; // Hoặc xử lý theo trường hợp của bạn
      }

      if (classMistakeModel != null) {
        futureMistakeClass = fetchMistakeClasses();
        _isInitialized = true;
      }
    }
  }

  Future<List<StudentDetailModel>> fetchMistakeClasses() async {
    print('fetchMistakeClasses được gọi với tháng: $selectedMonth');

    // Thêm kiểm tra null
    if (classMistakeModel == null || selectedMonth == null) {
      return [];
    }

    String monthToSearch = selectedMonth!.replaceFirst('Tháng ', '');

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', isEqualTo: classMistakeModel!.idClass)
        .get();

    print('Số lượng tài liệu nhận được: ${snapshot.docs.length}');

    return Future.wait(snapshot.docs.map((doc) async {
      return await StudentDetailModel.fromFirestore(doc, monthToSearch);
    }));
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

// Thêm hàm refresh
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
      child: Column(
        children: [
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: DropMenuWidget<String>(
                    hintText: 'Tháng',
                    items: getThangList(hocKy ?? ''),
                    selectedItem: selectedMonth,
                    onChanged: (newValue) {
                      if (newValue != null && newValue != selectedMonth) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                        futureMistakeClass = fetchMistakeClasses();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          TextField(
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black.withAlpha(50), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Mã HS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'Họ và Tên',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Số lần vi phạm',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Xem',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Cập nhật',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentDetailModel>>(
              future: futureMistakeClass,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return ListView(
                  children: snapshot.data
                          ?.map((e) => ItemClassMistakeStudent(
                                studentDetailModel: e,
                                month: selectedMonth,
                                onRefresh: _refreshData, // Thêm callback này
                              ))
                          .toList() ??
                      [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
