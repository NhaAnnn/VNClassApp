import 'package:flutter/material.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';
import 'package:vnclass/modules/classes/widget/all_classes_card.dart';
import 'package:vnclass/modules/conduct/conduct_detail/widget/conduct_detail_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static String routeName = 'search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<StudentModel> _students = [];
  List<ClassModel> _classes = [];
  late TabController _tabController;

  final Map<String, List<dynamic>> _filteredResults = {};
  final List<String> _filteredCategories = ['Học Sinh', 'Lớp Học'];

  Future<void> getList() async {
    _students = await StudentController.fetchAllStudents();
    _classes = await ClassController.fetchAllClasses();
    print('Số học sinh: ${_students.length}');
    print('Số lớp học: ${_classes.length}');

    // Khởi tạo TabController sau khi lấy danh mục

    setState(() {}); // Cập nhật giao diện
  }

  void _filterResults(String query) {
    _filteredResults.clear();

    if (query.isEmpty) {
      setState(() {});
      return;
    }

    final studentResults = _students
        .where((student) =>
            student.studentName!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final classResults = _classes
        .where((classItem) =>
            classItem.className!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (studentResults.isNotEmpty) {
      _filteredResults['Học Sinh'] = studentResults;
    }
    if (classResults.isNotEmpty) {
      _filteredResults['Lớp Học'] = classResults;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getList();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Giải phóng tài nguyên khi không sử dụng nữa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(title: 'Tìm kiếm'),
          TabBar(
            controller: _tabController,
            tabs: _filteredCategories.map((category) {
              return Tab(text: category);
            }).toList(),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.05,
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02),
            child: TextField(
              autofocus: true,
              controller: _searchController,
              onChanged: _filterResults,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _filteredCategories.map((category) {
                return _filteredResults[category]?.isEmpty ?? true
                    ? Center(
                        child: Text(
                          'Chưa có kết quả phù hợp',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredResults[category]!.length,
                        itemBuilder: (context, index) {
                          final result = _filteredResults[category]![index];
                          if (result is ClassModel) {
                            return AllClassesCard(classModel: result);
                          } else if (result is StudentModel) {
                            List<String> months = [
                              'Học kì 1',
                              'Tháng 9',
                              'Tháng 10',
                              'Tháng 11',
                              'Tháng 12',
                              'Học kì 2',
                              'Tháng 1',
                              'Tháng 2',
                              'Tháng 3',
                              'Tháng 4',
                              'Tháng 5',
                              'Cả năm',
                            ];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: months.map((month) {
                                return _studentSearch(month, result);
                              }).toList(),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentSearch(String month, dynamic result) {
    int monthKey = Getmonthnow.getMonthNumber(month);
    if (month.contains('Học kì 1')) monthKey = 100;
    if (month.contains('Học kì 2')) monthKey = 200;
    if (month.contains('Cả năm')) monthKey = 300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Text(
            month,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ConductDetailCard(
          monthKey: monthKey,
          studentModel: result,
        ),
      ],
    );
  }
}
