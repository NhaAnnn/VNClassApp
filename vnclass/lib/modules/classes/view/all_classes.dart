import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/widget/all_classes_card.dart';
import 'package:vnclass/modules/classes/widget/create_list_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/create_one_class_dialog.dart';

class AllClasses extends StatefulWidget {
  const AllClasses({super.key});
  static String routeName = 'all_classes';

  @override
  State<AllClasses> createState() => _AllClassesState();
}

class _AllClassesState extends State<AllClasses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: 'Danh sách các lớp',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ButtonN(
                            colorText: Colors.black,
                            color: Colors.cyan.shade200,
                            size: Size(
                              MediaQuery.of(context).size.width * 0.42,
                              MediaQuery.of(context).size.height * 0.05,
                            ),
                            label: 'Thêm 1 lớp học',
                            icon: Icon(
                              FontAwesomeIcons.circlePlus,
                              color: Colors.black,
                            ),
                            ontap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateOneClassDialog();
                                },
                              );
                              // CustomDialogWidget.show(context);
                            },
                          ),
                          ButtonN(
                            colorText: Colors.black,
                            color: Colors.cyan.shade200,
                            size: Size(
                              MediaQuery.of(context).size.width * 0.42,
                              MediaQuery.of(context).size.height * 0.05,
                            ),
                            label: 'Thêm DS lớp học',
                            icon: Icon(
                              FontAwesomeIcons.circlePlus,
                              color: Colors.black,
                            ),
                            ontap: () => {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateListClassDialog();
                                },
                              )
                            },
                          ),
                        ]),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropMenuWidget(
                          items: ['Học kỳ 1', 'Học kỳ 2'],
                          hintText: 'Học kỳ',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: DropMenuWidget(
                          items: ['2023-2024'],
                          hintText: 'Năm học',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SearchBar(
                      hintText: 'Search...',
                      leading: Icon(FontAwesomeIcons.searchengin),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<ClassModel>>(
                      future: ClassController.fetchAllClasses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Không có lớp học'));
                        }

                        // Dữ liệu đã được lấy thành công
                        List<ClassModel> classes = snapshot.data!;
                        return SingleChildScrollView(
                          child: Column(
                            children: classes.map((classModel) {
                              return AllClassesCard(
                                  classModel:
                                      classModel); // Truyền dữ liệu vào ClassDetailCard
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
