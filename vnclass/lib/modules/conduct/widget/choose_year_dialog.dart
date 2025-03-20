import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import '../../classes/class_detail/student_info/model/student_detail_model.dart';
import '../../conduct/view/all_conduct.dart';

class ChooseYearDialog extends StatefulWidget {
  const ChooseYearDialog({
    super.key,
    this.listStudent,
  });
  final List<StudentModel>? listStudent;
  @override
  State<ChooseYearDialog> createState() => _ChooseYearDialogState();
}

class _ChooseYearDialogState extends State<ChooseYearDialog> {
  List<String> listYear = [];

  List<StudentDetailModel> listStudentDetail = [];
  bool isLoading = true;
  String conduct1 = '';
  String conduct2 = '';
  String conduct3 = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    listYear = yearProvider.years;
    if (accountProvider.account!.goupID == 'hocSinh') {
      try {
        String studentID = accountProvider.account!.idAcc;
        listStudentDetail =
            await StudentDetailController.fetchStudentsByStudentId(studentID);
      } catch (e) {
        // Handle any errors here
        print("Error fetching data: $e");
      } finally {
        setState(() {
          isLoading = false; // Set loading to false once data is fetched
        });
      }
    } else if (accountProvider.account!.goupID == 'phuHuynh') {
      try {
        List<StudentDetailModel> studentDetails = [];
        for (var student in widget.listStudent!) {
          var details = await StudentDetailController.fetchStudentsByStudentId(
              student.id!);
          studentDetails.addAll(details);
        }
        listStudentDetail = studentDetails;
      } catch (e) {
        // Handle any errors here
        print("Error fetching data: $e");
      } finally {
        setState(() {
          isLoading = false; // Set loading to false once data is fetched
        });
      }
    } else {
      setState(() {
        isLoading = false; // Set loading to false once data is fetched
      });
    }
  }

  Future<void> getCouduct(String studentId) async {
    print('studentId: $studentId');
    conduct1 = await StudentDetailController.fetchConductTerm1ByID(studentId);
    conduct2 = await StudentDetailController.fetchConductTerm2ByID(studentId);
    conduct3 = await StudentDetailController.fetchConductAllYearByID(studentId);
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 0.02;
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

    return AlertDialog(
      title: (accountProvider.account!.goupID == 'hocSinh' ||
              accountProvider.account!.goupID == 'phuHuynh')
          ? Text(
              'Chọn Lớp',
              style: TextStyle(fontSize: 18),
            )
          : Text(
              'Chọn Năm Học',
              style: TextStyle(fontSize: 18),
            ),
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator()) // Show loading indicator
              : Column(
                  children: [
                    if (accountProvider.account!.goupID == 'hocSinh' ||
                        accountProvider.account!.goupID == 'phuHuynh') ...[
                      ...List.generate(listStudentDetail.length, (index) {
                        final studentDl = listStudentDetail[index];
                        getCouduct(studentDl.id!);
                        return Card(
                          elevation: 8,
                          margin: EdgeInsets.symmetric(vertical: paddingValue),
                          color: Colors.blueAccent,
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                StudentConductInfo.routeName,
                                arguments: {
                                  'studentModel': studentDl,
                                  'trainingScore': '',
                                  'conduct1': conduct1,
                                  'conduct2': conduct2,
                                  'conduct3': conduct3,
                                  'term': 300,
                                },
                              );
                            },
                            title: Text(
                              '${studentDl.studentName} Lớp ${studentDl.className!}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      ...List.generate(listYear.length, (index) {
                        final year = listYear[index];

                        return Card(
                          elevation: 8,
                          margin: EdgeInsets.symmetric(vertical: paddingValue),
                          color: Colors.blueAccent,
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AllConduct.routeName,
                                arguments: {'year': year},
                              );
                            },
                            title: Text(
                              year,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
