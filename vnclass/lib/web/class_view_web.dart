import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/widget/create_list_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/create_one_class_dialog.dart';
import 'package:vnclass/modules/search/search_screen.dart';

class ClassViewWeb extends StatefulWidget {
  const ClassViewWeb({super.key});

  @override
  State<ClassViewWeb> createState() => _ClassViewWebState();
}

class _ClassViewWebState extends State<ClassViewWeb> {
  List<String> years = [];
  String? selectedGrade;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    getYear();
  }

  Future<void> getYear() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('YEAR').get();

    for (var doc in querySnapshot.docs) {
      years.add(doc['_year']);
    }
    setState(() {});
  }

  Future<List<ClassModel>> _fetchFilteredClasses() async {
    var allClasses = await ClassController.fetchAllClasses();
    List<ClassModel> filteredClasses = allClasses;

    if (selectedGrade != null) {
      filteredClasses = filteredClasses.where((classModel) {
        return classModel.className != null &&
            classModel.className!.startsWith(selectedGrade!.substring(5));
      }).toList();
    }

    if (selectedYear != null) {
      filteredClasses = filteredClasses.where((classModel) {
        return classModel.year == selectedYear;
      }).toList();
    }

    return filteredClasses;
  }

  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(padding * 0.01),
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
                children: [
                  // Nút thêm lớp học
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: padding * 0.2, right: padding * 0.2),
                          child: SizedBox(
                            width: padding * 0.2,
                            height: padding * 0.02,
                            child: SearchBar(
                              hintText: 'Search...',
                              leading: Icon(
                                FontAwesomeIcons.searchengin,
                                size: 20,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, SearchScreen.routeName);
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: SizedBox(
                          width: padding * 0.03,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.circlePlus,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateOneClassDialog(
                                    onCreate: () => setState(() {}),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: SizedBox(
                          width: padding * 0.03,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.upload,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateListClassDialog(
                                    onCreate: () => setState(() {}),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Dropdown cho khối và năm học
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: padding * 0.1,
                        child: Text('Khối:'),
                      ),
                      SizedBox(
                        width: padding * 0.08,
                        height: padding * 0.035,
                        child: DropMenuWidget(
                          items: ['Khối 10', 'Khối 11', 'Khối 12'],
                          hintText: 'Tất cả',
                          borderColor: Colors.white,
                          textStyle:
                              TextStyle(fontSize: 13, color: Colors.black),
                          onChanged: (value) {
                            setState(() {
                              selectedGrade = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: padding * 0.1,
                        child: Text('Niên khóa:'),
                      ),
                      SizedBox(
                        width: padding * 0.08,
                        height: padding * 0.035,
                        child: DropMenuWidget(
                          selectedItem: selectedYear,
                          items: years,
                          hintText: 'Tất cả',
                          borderColor: Colors.white,
                          textStyle:
                              TextStyle(fontSize: 13, color: Colors.black),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Hiển thị danh sách lớp học dưới dạng bảng
                  Expanded(
                    child: FutureBuilder<List<ClassModel>>(
                      future: _fetchFilteredClasses(),
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

                        List<ClassModel> classes = snapshot.data!;
                        return SingleChildScrollView(
                          // scrollDirection: Axis.vertical,

                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                    label: Expanded(
                                        child: Center(child: Text('Tên lớp')))),
                                DataColumn(
                                    label: Expanded(
                                        child:
                                            Center(child: Text('Niên khóa')))),
                                DataColumn(
                                    label: Expanded(
                                        child: Center(child: Text('Sỉ số')))),
                                DataColumn(
                                    label: Expanded(
                                        child: Center(
                                            child: Text('Tên Giáo viên')))),
                                DataColumn(
                                    label: Expanded(
                                        child:
                                            Center(child: Text('Chức năng')))),
                              ],
                              rows: classes.map((classModel) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(classModel.className ?? '')),
                                    DataCell(Center(
                                        child: Text(classModel.year ?? ''))),
                                    DataCell(Center(
                                        child: Text(
                                            classModel.amount.toString()))),
                                    DataCell(
                                        Text(classModel.teacherName ?? '')),
                                    DataCell(Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            FontAwesomeIcons.solidEye,
                                            color: Colors.black,
                                            semanticLabel: 'Xem thông tin',
                                          ),
                                          onPressed: () {
                                            // Chỉnh sửa lớp học
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              FontAwesomeIcons.pencil,
                                              color: Colors.blueAccent),
                                          onPressed: () {
                                            // Chỉnh sửa lớp học
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              FontAwesomeIcons.solidTrashCan,
                                              color: Colors.redAccent),
                                          onPressed: () {
                                            // Xóa lớp học
                                          },
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
