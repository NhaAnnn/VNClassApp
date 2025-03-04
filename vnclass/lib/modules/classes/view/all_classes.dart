import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/widget/all_classes_card.dart';
import 'package:vnclass/modules/classes/widget/create_list_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/create_one_class_dialog.dart';
import 'package:vnclass/modules/search/search_screen.dart';

class AllClasses extends StatefulWidget {
  const AllClasses({super.key});
  static String routeName = 'all_classes';

  @override
  State<AllClasses> createState() => _AllClassesState();
}

class _AllClassesState extends State<AllClasses> {
  List<String> years = [];
  String? selectedGrade; // Biến trạng thái cho khối
  String? selectedYear; // Biến trạng thái cho năm học

  @override
  void initState() {
    super.initState();
    getYear();
  }

  Future<void> _refreshClasses() async {
    setState(() {
      // Triggers a rebuild to fetch data again
    });
  }

  Future<void> getYear() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('YEAR').get();

    for (var doc in querySnapshot.docs) {
      years.add(doc['_year']);
    }

    setState(() {}); // Cập nhật lại giao diện sau khi lấy dữ liệu
  }

  Future<List<ClassModel>> _fetchFilteredClasses() async {
    var allclasses = await ClassController.fetchAllClasses();
    List<ClassModel> filteredClass = [];
    if (selectedGrade == null && selectedYear == null) {
      return allclasses; // Hàm này nên trả về tất cả lớp học
    } else if (selectedGrade != null && selectedYear != null) {
      var result = await ClassController.fetchAllClassesByYear(selectedYear!);

      for (var newResult in result) {
        if (newResult.className != null && newResult.className!.length >= 2) {
          String firstTwoChars = newResult.className!.substring(0, 2);
          if (selectedGrade!.contains('Khối 10') &&
              firstTwoChars.contains('10')) {
            filteredClass.add(newResult);
          } else if (selectedGrade!.contains('Khối 11') &&
              firstTwoChars.contains('11')) {
            filteredClass.add(newResult);
          } else if (selectedGrade!.contains('Khối 12') &&
              firstTwoChars.contains('12')) {
            filteredClass.add(newResult);
          }
        }
      }
      return filteredClass;
    } else {
      for (var newResult in allclasses) {
        if (newResult.className != null && newResult.className!.length >= 2) {
          String firstTwoChars = newResult.className!.substring(0, 2);
          if (selectedGrade!.contains('Khối 10') &&
              firstTwoChars.contains('10')) {
            filteredClass.add(newResult);
          } else if (selectedGrade!.contains('Khối 11') &&
              firstTwoChars.contains('11')) {
            filteredClass.add(newResult);
          } else if (selectedGrade!.contains('Khối 12') &&
              firstTwoChars.contains('12')) {
            filteredClass.add(newResult);
          }
        }
      }
      return filteredClass;
    }
  }

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
                  // Các nút thêm lớp học
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ButtonN(
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
                                  return CreateOneClassDialog(
                                    onCreate: _refreshClasses,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Expanded(
                          child: ButtonN(
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
                            ontap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateListClassDialog(
                                    onCreate: _refreshClasses,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dropdown cho khối và năm học
                  Row(
                    children: [
                      Expanded(
                        child: DropMenuWidget(
                          items: ['Khối 10', 'Khối 11', 'Khối 12'],
                          hintText: 'Khối',
                          onChanged: (value) {
                            setState(() {
                              selectedGrade = value; // Cập nhật khối đã chọn
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: DropMenuWidget(
                          selectedItem: selectedYear,
                          items: years,
                          hintText: 'Năm học',
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value; // Cập nhật năm học đã chọn
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  // Thanh tìm kiếm
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SearchBar(
                      hintText: 'Search...',
                      leading: Icon(FontAwesomeIcons.searchengin),
                      onTap: () {
                        Navigator.pushNamed(context, SearchScreen.routeName);
                      },
                    ),
                  ),
                  // Hiển thị danh sách lớp học
                  Expanded(
                    child: FutureBuilder<List<ClassModel>>(
                      future: _fetchFilteredClasses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Hiển thị khung xương khi đang tải
                          return SkeletonLoader(
                            builder: Column(
                              children: List.generate(
                                  3,
                                  (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      )),
                            ),
                            items: 1, // Số lượng skeleton items
                            period: const Duration(
                                seconds: 2), // Thời gian hiệu ứng
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Không có lớp học'));
                        }

                        List<ClassModel> classes = snapshot.data!;
                        return ListView.builder(
                          itemCount: classes.length,
                          itemBuilder: (context, index) {
                            return AllClassesCard(
                              classModel: classes[index],
                              onUpdate: _refreshClasses,
                            );
                          },
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
