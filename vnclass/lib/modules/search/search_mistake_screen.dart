import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/conduct/conduct_detail/widget/conduct_detail_card.dart';
import 'package:vnclass/modules/mistake/controllers/mistake_repository.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/widget/item_class_mistake.dart';
import 'package:vnclass/modules/mistake/widget/item_class_mistake_student.dart';

class SearchMistakeScreen extends StatefulWidget {
  const SearchMistakeScreen({super.key});
  static String routeName = 'search_mistake_screen';

  @override
  _SearchMistakeScreenState createState() => _SearchMistakeScreenState();
}

class _SearchMistakeScreenState extends State<SearchMistakeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<StudentDetailModel> _students = [];
  List<ClassMistakeModel> _classes = [];
  late TabController _tabController;

  final Map<String, List<dynamic>> _filteredResults = {};
  final List<String> _filteredCategories = [
    'Lớp Học',
    'Học Sinh',
  ];

  Future<void> getList() async {
    final mistakeRepository = MistakeRepository();

    _classes = await mistakeRepository.fetchMistakeClasses('CLASS');

    List<StudentDetailModel> allStudents = [];
    for (var classItem in _classes) {
      final students = await fetchStudentMistakeClass(classItem.idClass);
      allStudents.addAll(students
          .where((student) => student != null)
          .cast<StudentDetailModel>());

      _students = allStudents;
    }

    print('Số học sinh: ${_students.length}');
    print('Số lớp học: ${_classes.length}');
    print('Số học sinh: $_students');

    setState(() {});
  }

  Future<List<StudentDetailModel?>> fetchStudentMistakeClass(
      String idClass) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .where('Class_id', isEqualTo: idClass)
        .get();

    final data = await Future.wait(
      snapshot.docs
          .map((doc) => StudentDetailModel.fromFirestoreTotalErrors(doc)),
    );

    return data;
  }

  void filterResults(String query) {
    _filteredResults.clear();

    if (query.isEmpty) {
      setState(() {});
      return;
    }

    final studentResults = _students
        .where((student) =>
            student.nameStudent.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final classResults = _classes
        .where((classItem) =>
            classItem.className.toLowerCase().contains(query.toLowerCase()))
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
    _tabController =
        TabController(length: _filteredCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              onChanged: filterResults,
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
                        itemCount: _filteredResults[category]?.length ?? 0,
                        itemBuilder: (context, index) {
                          var result = _filteredResults[category]![index];
                          List<String> semesters = [
                            'Học kỳ 1',
                            'Học kỳ 2',
                            'Cả năm',
                          ];
                          if (result is ClassMistakeModel) {
                            return Column(
                              children: semesters.map((semester) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        semester,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ItemClassModels(
                                        classMistakeModel: result,
                                        hocKy: semester,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(), // Convert the iterable to a list
                            );
                          } else if (result is StudentDetailModel) {
                            List<String> months = [
                              'Tháng 1',
                              'Tháng 2',
                              'Tháng 3',
                              'Tháng 4',
                              'Tháng 5',
                              'Tháng 9',
                              'Tháng 10',
                              'Tháng 11',
                              'Tháng 12',
                            ];
                            return Column(
                              children: months.map((month) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: studentSearch(month, result),
                                );
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

  Widget studentSearch(String month, StudentDetailModel result) {
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
        ItemClassMistakeStudent(
          month: month,
          studentDetailModel: result,
          isSearch: true,
        ),
      ],
    );
  }
}
