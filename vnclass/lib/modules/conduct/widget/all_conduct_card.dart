import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/conduct/conduct_detail/view/conduct_detail.dart';

class AllConductCard extends StatefulWidget {
  const AllConductCard({
    super.key,
    required this.classModel,
    required this.monthKey,
    this.onSelect,
  });

  final ClassModel classModel;
  final int monthKey;
  final Function(ClassModel)? onSelect;
  @override
  State<AllConductCard> createState() => _AllConductCardState();
}

class _AllConductCardState extends State<AllConductCard> {
  ClassModel get classModel => widget.classModel;
  int get monthKey => widget.monthKey;

  void _openRightDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          widget.onSelect!(classModel);
          _openRightDrawer(context);
        }
      },
      child: Card(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blueAccent, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    _buildRow('Lớp:', classModel.className.toString()),
                    _buildRow('Niên khóa:', classModel.year.toString()),
                    _buildRow('Sỉ số:', classModel.amount.toString()),
                    _buildRow('GVCN:', classModel.teacherName.toString()),
                    _buildConductRow('Hạnh kiểm:', 'Tốt', 'Đạt'),
                    _buildConductRow('', 'Khá', 'Chưa Đạt'),
                  ],
                ),
              ),
              if (!kIsWeb) ...[
                GestureDetector(
                  onTap: () => {
                    Navigator.of(context).pushNamed(
                      ConductDetail.routeName,
                      arguments: {
                        'classID': classModel.id,
                        'className': classModel.className,
                        'monthKey': monthKey,
                      },
                    )
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
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

  Widget _buildRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: kIsWeb
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 27, 78, 121))
                    : TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(flex: 7, child: Text(value)),
          ],
        ),
      ),
    );
  }

  Widget _buildConductRow(
      String label, String conductType1, String conductType2) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
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
                child: Text(
              '$conductType1:',
              style: kIsWeb
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 27, 78, 121))
                  : TextStyle(fontWeight: FontWeight.bold),
            )),
            Expanded(child: _buildConductFutureBuilder(conductType1)),
            Expanded(
                flex: 2,
                child: Text(
                  '$conductType2:',
                  style: kIsWeb
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 27, 78, 121))
                      : TextStyle(fontWeight: FontWeight.bold),
                )),
            Expanded(child: _buildConductFutureBuilder(conductType2)),
          ],
        ),
      ),
    );
  }

  Widget _buildConductFutureBuilder(String conductType) {
    Future<int?> fetchConductData() {
      if (monthKey == 100) {
        return StudentDetailController.fetchStudentsConductTerm1ByClass(
            classModel.id!, conductType);
      } else if (monthKey == 200) {
        return StudentDetailController.fetchStudentsConductTerm2ByClass(
            classModel.id!, conductType);
      } else if (monthKey == 300) {
        return StudentDetailController.fetchStudentsConductAllTermByClass(
            classModel.id!, conductType);
      } else {
        return StudentDetailController.fetchStudentsConductMonthByClass(
          classModel.id!,
          Getmonthnow.getMonthKey(monthKey),
          conductType,
        );
      }
    }

    return FutureBuilder<int?>(
      future: fetchConductData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...'); // Loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Error message
        } else if (!snapshot.hasData || snapshot.data == 0) {
          return Text('0'); // Default value if no data
        } else {
          return Text(snapshot.data.toString());
        }
      },
    );
  }
}
