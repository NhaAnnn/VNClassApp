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
  });

  final ClassModel classModel;
  final int monthKey;

  @override
  State<AllConductCard> createState() => _AllConductCardState();
}

class _AllConductCardState extends State<AllConductCard> {
  ClassModel get classModel => widget.classModel;
  int get monthKey => widget.monthKey;

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return Card(
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blueAccent, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  _buildRow('Lớp:', classModel.className.toString()),
                  SizedBox(height: paddingValue * 0.02),
                  _buildRow('Niên khóa:', classModel.year.toString()),
                  SizedBox(height: paddingValue * 0.02),
                  _buildRow('Sỉ số:', classModel.amount.toString()),
                  SizedBox(height: paddingValue * 0.02),
                  _buildRow('GVCN:', classModel.teacherName.toString()),
                  SizedBox(height: paddingValue * 0.02),
                  _buildConductRow('Hạnh kiểm:', 'Tốt', 'Đạt'),
                  SizedBox(height: paddingValue * 0.02),
                  _buildConductRow('', 'Khá', 'Chưa đạt'),
                ],
              ),
            ),
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
              child: Padding(
                padding: EdgeInsets.all(paddingValue * 0.02),
                child: Icon(
                  FontAwesomeIcons.angleRight,
                  size: 36,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(flex: 7, child: Text(value)),
      ],
    );
  }

  Widget _buildConductRow(
      String label, String conductType1, String conductType2) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            child: Text('$conductType1:',
                style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: _buildConductFutureBuilder(conductType1)),
        Expanded(
            flex: 2,
            child: Text('$conductType2:',
                style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: _buildConductFutureBuilder(conductType2)),
      ],
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
