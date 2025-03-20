import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/search_bar.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/widget/all_classes_card.dart';
import 'package:vnclass/modules/classes/widget/create_list_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/create_one_class_dialog.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/search/search_screen.dart';

class AllClasses extends StatefulWidget {
  const AllClasses({super.key});
  static String routeName = 'all_classes';

  @override
  State<AllClasses> createState() => _AllClassesState();
}

class _AllClassesState extends State<AllClasses> {
  // List<String> years = [];
  String? selectedGrade; // Biến trạng thái cho khối
  String? selectedYear; // Biến trạng thái cho năm học

  @override
  void initState() {
    super.initState();
    // getYear();
    selectedYear = Provider.of<YearProvider>(context, listen: false).years.last;
    selectedGrade = 'Tất cả';
  }

  Future<void> _refreshClasses() async {
    setState(() {});
  }

  Future<List<ClassModel>> _fetchFilteredClasses() async {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    List<ClassModel> allClasses;

    if (accountProvider.account!.goupID == 'giaoVien') {
      allClasses = await ClassController.fetchAllClassesByYearAndTearcher(
          selectedYear!, accountProvider.account!.idAcc);
    } else {
      allClasses = await ClassController.fetchAllClassesByYear(selectedYear!);
    }

    // If 'Tất cả' is selected, return all classes
    if (selectedGrade == 'Tất cả') {
      return allClasses;
    }

    // Filter classes based on selected grade
    return _filterClassesByGrade(allClasses);
  }

  List<ClassModel> _filterClassesByGrade(List<ClassModel> classes) {
    List<ClassModel> filteredClasses = [];

    for (var classModel in classes) {
      if (classModel.className != null && classModel.className!.length >= 2) {
        String firstTwoChars = classModel.className!.substring(0, 2);
        if (selectedGrade!.contains('Khối 10') &&
                firstTwoChars.contains('10') ||
            selectedGrade!.contains('Khối 11') &&
                firstTwoChars.contains('11') ||
            selectedGrade!.contains('Khối 12') &&
                firstTwoChars.contains('12')) {
          filteredClasses.add(classModel);
        }
      }
    }

    return filteredClasses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(title: 'Danh sách các lớp'),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                // Các nút thêm lớp học
                Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceAround, // Distribute buttons evenly
                      children: [
                        ButtonN(
                          label: 'Thêm 1 lớp',
                          icon: Icon(FontAwesomeIcons.circlePlus,
                              color: Colors.black),
                          color: Colors.cyan.shade200,
                          colorText: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          ontap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CreateOneClassDialog(
                                    onCreate: _refreshClasses);
                              },
                            );
                          },
                        ),
                        // Spacing between buttons
                        ButtonN(
                          label: 'Thêm DS lớp',
                          icon: Icon(FontAwesomeIcons.upload,
                              color: Colors.black),
                          color: Colors.cyan.shade200,
                          borderRadius: BorderRadius.circular(10),
                          colorText: Colors.black,
                          ontap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CreateListClassDialog(
                                    onCreate: _refreshClasses);
                              },
                            );
                          },
                        ),
                      ],
                    )),
                // Dropdown cho khối và năm học
                Row(
                  children: [
                    Expanded(
                      child: DropMenuWidget(
                        items: ['Tất cả', 'Khối 10', 'Khối 11', 'Khối 12'],
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
                        items: Provider.of<YearProvider>(context, listen: false)
                            .years,
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
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01,
                      top: MediaQuery.of(context).size.width * 0.02),
                  child: CustomSearchBar(
                    hintText: 'Search...',
                    onTap: () {
                      Navigator.pushNamed(context, SearchScreen.routeName);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Hiển thị danh sách lớp học
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: FutureBuilder<List<ClassModel>>(
                future: _fetchFilteredClasses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SkeletonLoader(
                      builder: Column(
                        children: List.generate(
                            2,
                            (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )),
                      ),
                      items: 1, // Số lượng skeleton items
                      period: const Duration(seconds: 2), // Thời gian hiệu ứng
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không có lớp học'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return AllClassesCard(
                        classModel: snapshot.data![index],
                        onUpdate: _refreshClasses,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
