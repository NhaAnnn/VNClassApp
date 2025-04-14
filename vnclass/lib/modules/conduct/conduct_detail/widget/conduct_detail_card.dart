import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/controller/conduct_month_controller.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info_month.dart';

class ConductDetailCard extends StatefulWidget {
  const ConductDetailCard({
    super.key,
    required this.studentModel,
    required this.monthKey,
    this.onSelect,
  });

  final StudentDetailModel studentModel;
  final int monthKey;
  final Function(StudentDetailModel, String, String)? onSelect;
  @override
  State<ConductDetailCard> createState() => _ConductDetailCardState();
}

class _ConductDetailCardState extends State<ConductDetailCard> {
  StudentDetailModel get studentModel => widget.studentModel;
  int get monthKey => widget.monthKey;
  String trainingScore = '';
  String conduct = '';

  void _openRightDrawer(BuildContext context) {
    print(studentModel);
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          widget.onSelect!(studentModel, conduct, trainingScore);
          _openRightDrawer(context);
        }
      },
      child: Card(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blueAccent, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (widget.monthKey >= 100) ...[
                      _buildConductDetailRow(
                          'Mã học sinh:', studentModel.id.toString()),
                      _buildConductDetailRow(
                          'Họ và tên:', studentModel.studentName.toString()),
                      _buildConductInfoDetailRow('Hạnh kiểm:',
                          studentModel.id.toString(), monthKey, 1),
                    ] else ...[
                      _buildConductDetailRow(
                          'Mã học sinh:', studentModel.id.toString()),
                      _buildConductDetailRow(
                          'Họ và tên:', studentModel.studentName.toString()),
                      _buildConductInfoDetailRow('Điểm rèn luyện:',
                          studentModel.id.toString(), monthKey, 0),
                      _buildConductInfoDetailRow('Hạnh kiểm:',
                          studentModel.id.toString(), monthKey, 1),
                    ]
                  ],
                ),
              ),
              if (!kIsWeb) ...[
                GestureDetector(
                  onTap: () => {
                    if (monthKey >= 100)
                      {
                        Navigator.of(context).pushNamed(
                          StudentConductInfo.routeName,
                          arguments: {
                            'studentModel': studentModel,
                            'trainingScore': trainingScore,
                            'conduct': conduct,
                            'term': monthKey,
                          },
                        ),
                      }
                    else
                      {
                        Navigator.of(context).pushNamed(
                          StudentConductInfoMonth.routeName,
                          arguments: {
                            'studentID': studentModel.id,
                            'studentName': studentModel.studentName,
                            'monthKey': monthKey,
                            'trainingScore': trainingScore,
                            'conduct': conduct,
                          },
                        ),
                      }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      FontAwesomeIcons.angleRight,
                      size: 36,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConductDetailRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: kIsWeb
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 27, 78, 121))
                    : TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConductInfoDetailRow(
      String label, String studentID, int monthKey, int n) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: kIsWeb
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 27, 78, 121))
                    : TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 6,
              child: _buildConductInfoText(studentID, monthKey, n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConductInfoText(String studentID, int monthKey, int n) {
    Future<String> fetchConductData() {
      if (monthKey == 100) {
        return StudentDetailController.fetchConductTerm1ByID(studentID);
      } else if (monthKey == 200) {
        return StudentDetailController.fetchConductTerm2ByID(studentID);
      } else if (monthKey == 300) {
        return StudentDetailController.fetchConductAllYearByID(studentID);
      } else {
        return ConductMonthController.fetchConductMonthByOneMonth(
            studentID, Getmonthnow.getMonthKey(monthKey), n);
      }
    }

    return FutureBuilder<String>(
      future: fetchConductData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading...', // Hoặc CircularProgressIndicator()
            style: TextStyle(color: Colors.black),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Có lỗi: ${snapshot.error}',
            style: TextStyle(color: Colors.red),
          );
        } else if (snapshot.hasData) {
          if (n == 0) {
            trainingScore = snapshot.data ?? '';
          } else {
            conduct = snapshot.data ?? '';
          }
          return Text(
            snapshot.data ?? '',
            style: TextStyle(color: Colors.black),
          );
        } else {
          return Text(
            'Không có dữ liệu.',
            style: TextStyle(color: Colors.black),
          );
        }
      },
    );
  }
}
