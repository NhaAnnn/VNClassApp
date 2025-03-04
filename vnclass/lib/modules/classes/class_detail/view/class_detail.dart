import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';
import 'package:vnclass/modules/classes/class_detail/widget/class_detail_card.dart';

class ClassDetail extends StatefulWidget {
  const ClassDetail({
    super.key,
    // this.classID,
  });
  static String routeName = 'class_detail';
  // final String? classID;

  @override
  State<ClassDetail> createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetail> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Lấy dữ liệu từ arguments
    final String classID = args['classID'] as String;
    final String className = args['className'] as String;
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: 'Lớp $className',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(paddingValue * 0.02),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(paddingValue * 0.02),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Danh sách lớp:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: paddingValue * 0.02),
                    child: SearchBar(
                      hintText: 'Search...',
                      leading: Icon(FontAwesomeIcons.searchengin),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<StudentModel>>(
                      future:
                          StudentDetailController.fetchStudentsByClass(classID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SkeletonLoader(
                            builder: Column(
                              children: List.generate(
                                  3,
                                  (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      )),
                            ),
                            items: 2, // Số lượng skeleton items
                            period: const Duration(
                                seconds: 2), // Thời gian hiệu ứng
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Không có học sinh'));
                        }

                        // Dữ liệu đã được lấy thành công
                        List<StudentModel> students = snapshot.data!;
                        return SingleChildScrollView(
                          child: Column(
                            children: students.map((studentModel) {
                              return ClassDetailCard(
                                studentModel: studentModel,
                                className: className,
                              ); // Truyền dữ liệu vào ClassDetailCard
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
