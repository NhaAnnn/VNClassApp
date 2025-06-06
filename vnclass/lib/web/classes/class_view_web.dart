import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vnclass/common/widget/drop_menu_widget.dart';

import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/widget/all_classes_card.dart';
import 'package:vnclass/modules/classes/widget/create_list_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/create_one_class_dialog.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/web/classes/widget/student_widget.dart';

class ClassViewWeb extends StatefulWidget {
  const ClassViewWeb({super.key});

  static String routeName = 'class_view_web';
  @override
  State<ClassViewWeb> createState() => _ClassViewWebState();
}

class _ClassViewWebState extends State<ClassViewWeb> {
  List<String> years = [];
  String? selectedGrade;
  String? selectedYear;
  // List<ClassModel> fetchedClasses = [];
  ClassModel? selectedClass;
  late AccountProvider accountProvider;

  List<ClassModel> _allClasses = [];
  List<ClassModel> _filteredClasses = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountProvider>(context, listen: false);

    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    selectedYear =
        yearProvider.years.isNotEmpty ? yearProvider.years.first : '';

    loadClasses().then((classes) {
      setState(() {
        _allClasses = classes;
        _filteredClasses = classes;
      });
    });
  }

  Future<void> _refreshClasses() async {
    final classes = await loadClasses(); // Fetch latest classes
    setState(() {
      _allClasses = classes; // Update the all classes list
      _filteredClasses = classes; // You can also reset filtered classes
    });
  }

  void _filterClasses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClasses = _allClasses.where((classItem) {
        final matchesGrade = selectedGrade == null ||
            classItem.className!.startsWith(selectedGrade!.substring(5));
        final matchesYear =
            selectedYear == null || classItem.year == selectedYear;
        final matchesSearch =
            classItem.className!.toLowerCase().contains(query);

        return matchesGrade && matchesYear && matchesSearch;
      }).toList();
    });
  }

  Future<List<ClassModel>> loadClasses() async {
    print(accountProvider.account!.goupID);
    List<ClassModel> fetchedClasses = await ClassController.fetchAllClasses();

    if (accountProvider.account!.goupID == 'giaoVien' && selectedYear != null) {
      fetchedClasses = await ClassController.fetchAllClassesByYearAndTearcher(
          selectedYear!, accountProvider.account!.idAcc);
      print('giaoVien fetchedClasses: $fetchedClasses');
    } else if (accountProvider.account!.goupID == 'banGH' &&
        selectedYear != null) {
      fetchedClasses =
          await ClassController.fetchAllClassesByYear(selectedYear!);
    } else {
      fetchedClasses = await ClassController.fetchAllClassesByTearcherID(
          accountProvider.account!.idAcc);
    }

    return fetchedClasses;
  }

  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.width * 1;
    final yearProvider = Provider.of<YearProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: padding * 0.03, left: padding * 0.03),
            child: Text(
              'Danh sách lớp học:',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(left: padding * 0.02, right: padding * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút thêm lớp học
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: padding * 0.3,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => _filterClasses(),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD3D3D3), width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E90FF), width: 2.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (accountProvider.account!.goupID == 'banGH') ...[
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.circlePlus,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CreateOneClassDialog(
                                  onCreate: () async {
                                    await _refreshClasses();
                                  },
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.upload,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CreateListClassDialog(
                                  onCreate: () async {
                                    await _refreshClasses();
                                  },
                                );
                              },
                            );
                            loadClasses();
                          },
                        ),
                      ]
                    ],
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: padding * 0.15,
                        child: Row(
                          children: [
                            Text('Khối:'),
                            SizedBox(width: 10),
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                value: selectedGrade,
                                items: ['Khối 10', 'Khối 11', 'Khối 12']
                                    .map((grade) => DropdownMenuItem<String>(
                                          value: grade,
                                          child: Text(
                                            grade,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ))
                                    .toList(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(0xFFD3D3D3), width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(0xFFD3D3D3), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(0xFF1E90FF), width: 2.0),
                                  ),
                                  hintText: 'Tất cả',
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                isExpanded: true,
                                itemHeight: null,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGrade = value;
                                    _filterClasses();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: padding * 0.18,
                        child: Row(
                          children: [
                            Text('Niên khóa:'),
                            SizedBox(width: 10),
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                value: selectedYear,
                                items: yearProvider.years
                                    .map((year) => DropdownMenuItem<String>(
                                          value: year,
                                          child: Text(
                                            year,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ))
                                    .toList(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(0xFFD3D3D3), width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(0xFFD3D3D3), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Color(0xFF1E90FF), width: 2.0),
                                  ),
                                  hintText: 'Tất cả',
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                isExpanded: true,
                                itemHeight: null,
                                onChanged: (value) {
                                  setState(() {
                                    selectedYear = value;
                                    _filterClasses();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Expanded(
                    child: _filteredClasses
                            .isEmpty // Check if _filteredClasses is empty
                        ? Center(child: Text('Không có lớp học'))
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 16.0,
                              runSpacing: 16.0,
                              children: _filteredClasses.map((classModel) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.25, // Adjust width as needed

                                  child: AllClassesCard(
                                    classModel: classModel,
                                    onUpdate: _refreshClasses,
                                    onSelect: (selectedClassModel) {
                                      setState(() {
                                        // Cập nhật lớp học đã chọn
                                        selectedClass = selectedClassModel;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: selectedClass != null
            ? StudentWidget(
                classModel: selectedClass!,
              )
            : Center(child: Text('Chưa chọn lớp học')),
      ),
    );
  }
}
