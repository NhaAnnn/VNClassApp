import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/search_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/widget/conduct_detail_card.dart';
import 'package:vnclass/modules/search/search_screen.dart';
import 'package:vnclass/web/conduct/widget/conduct_student_month.dart';
import 'package:vnclass/web/conduct/widget/conduct_student_term.dart';

class ConductDetailViewWeb extends StatefulWidget {
  const ConductDetailViewWeb(
      {super.key, this.classID, this.className, required this.monthKey});
  static String routeName = 'conduct_detail';

  final String? classID;
  final String? className;
  final int monthKey;

  @override
  State<ConductDetailViewWeb> createState() => _ConductDetailViewWebState();
}

class _ConductDetailViewWebState extends State<ConductDetailViewWeb> {
  StudentDetailModel? selectedStudentDetail;
  String? conduct;
  String? trainingScore;
  List<StudentDetailModel> _students = [];
  List<StudentDetailModel> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents(widget.classID!);
  }

  void _filterClasses(String query) {
    setState(() {
      _filteredStudents = _students.where((studentItem) {
        return studentItem.studentName!
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _loadStudents(String classID) async {
    try {
      var students =
          await StudentDetailController.fetchStudentsByClass(classID);
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false; // Set loading to false once data is loaded
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading to false even if there's an error
      });
      // Handle error (show a message, log, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? classID;
    final String? className;
    final int monthKey;

    classID = widget.classID;
    className = widget.className;
    monthKey = widget.monthKey;

    String month;
    if (monthKey == 100) {
      month = 'Học kì 1';
    } else if (monthKey == 200) {
      month = 'Học kì 2';
    } else if (monthKey == 300) {
      month = 'Cả năm';
    } else {
      month = Getmonthnow.getMonthName(monthKey);
    }
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(
            title: 'Hạnh kiểm lớp $className $month',
            backgroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(paddingValue * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          'Thông tin học sinh:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(width: paddingValue * 0.02),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterClasses,
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
                  ),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child:
                                CircularProgressIndicator()) // Show loading indicator while data is loading
                        : _filteredStudents.isEmpty
                            ? Center(
                                child: Text(
                                    'Không có học sinh')) // Message when no students found
                            : SingleChildScrollView(
                                child: Wrap(
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  children: _filteredStudents.map((student) {
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.25, // Adjust width as needed
                                      child: ConductDetailCard(
                                        studentModel: student,
                                        monthKey: widget
                                            .monthKey, // Use widget.monthKey directly
                                        onSelect: (selectedStudentDetailModel,
                                            conductData,
                                            trainingScoreData) async {
                                          setState(() {
                                            selectedStudentDetail =
                                                selectedStudentDetailModel;
                                            conduct = conductData;
                                            trainingScore = trainingScoreData;
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 1,
        child: monthKey >= 100
            ? ConductStudentTerm(
                studentDetailModel: selectedStudentDetail,
                conduct: conduct,
                term: monthKey,
              )
            : ConductStudentMonth(
                studentDetailModel: selectedStudentDetail,
                monthKey: monthKey,
                trainingScore: trainingScore,
                conduct: conduct,
              ),
      ),
    );
  }
}
