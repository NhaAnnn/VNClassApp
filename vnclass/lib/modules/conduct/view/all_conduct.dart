import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/search_bar.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/conduct/widget/all_conduct_card.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/search/search_screen.dart';

class AllConduct extends StatefulWidget {
  const AllConduct({super.key});
  static String routeName = 'all_conduct';

  @override
  State<AllConduct> createState() => _AllConductState();
}

class _AllConductState extends State<AllConduct> {
  String selectedMonth = '';
  String selectedTerm = '';
  List<String> validMonths = [];

  @override
  void initState() {
    super.initState();
    // Determine the initial term and month based on the current month
    String currentMonth = Getmonthnow.currentMonth();
    selectedTerm = _getTermFromMonth(currentMonth);
    validMonths = _getValidMonths(selectedTerm);

    // Set selectedMonth to the current month if it's valid, otherwise, use the first valid month
    selectedMonth = validMonths.contains(currentMonth)
        ? currentMonth
        : (validMonths.isNotEmpty ? validMonths.first : '');
  }

  String _getTermFromMonth(String month) {
    if (month.contains('Tháng 1') ||
        month.contains('Tháng 2') ||
        month.contains('Tháng 3') ||
        month.contains('Tháng 4') ||
        month.contains('Tháng 5')) {
      return 'Học kỳ 2';
    } else if (month.contains('Tháng 9') ||
        month.contains('Tháng 10') ||
        month.contains('Tháng 11') ||
        month.contains('Tháng 12')) {
      return 'Học kỳ 1';
    }
    return 'Cả năm';
  }

  void _updateTermAndMonths(String newTerm) {
    setState(() {
      selectedTerm = newTerm;
      validMonths = _getValidMonths(selectedTerm);

      // Prioritize current month, if available, otherwise default to the first valid month
      String currentMonth = Getmonthnow.currentMonth();
      selectedMonth = validMonths.contains(currentMonth)
          ? currentMonth
          : (validMonths.isNotEmpty ? validMonths.first : '');
    });
  }

  List<String> _getValidMonths(String term) {
    if (term == 'Học kỳ 2') {
      return [
        'Học kỳ 2',
        'Tháng 1',
        'Tháng 2',
        'Tháng 3',
        'Tháng 4',
        'Tháng 5'
      ];
    } else if (term == 'Học kỳ 1') {
      return ['Học kỳ 1', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    }
    return ['Cả năm'];
  }

  int _getMonthKey(String selectedMonth) {
    if (selectedMonth.contains('Học kỳ 1')) {
      return 100;
    } else if (selectedMonth.contains('Học kỳ 2')) {
      return 200;
    } else if (selectedMonth.contains('Cả năm')) {
      return 300;
    } else {
      return Getmonthnow.getMonthNumber(selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 1;
    final accountProvider = Provider.of<AccountProvider>(context);

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Truy cập các tham số
    final year = args['year'];
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(title: 'Danh sách các lớp $selectedTerm'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(paddingValue * 0.02),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropMenuWidget(
                            items: ['Học kỳ 1', 'Học kỳ 2', 'Cả năm'],
                            hintText: 'Học kỳ',
                            selectedItem: selectedTerm,
                            onChanged: (termValue) {
                              // Call _updateTermAndMonths to update both term and months
                              _updateTermAndMonths(termValue!);
                            },
                          ),
                        ),
                        SizedBox(width: paddingValue * 0.02),
                        Expanded(
                          child: DropMenuWidget(
                            items: validMonths,
                            key: ValueKey(validMonths), // Add a ValueKey
                            selectedItem: selectedMonth,
                            hintText: 'Tháng',
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingValue * 0.03),
                      child: CustomSearchBar(
                        hintText: 'Search...',
                        onTap: () {
                          Navigator.pushNamed(context, SearchScreen.routeName);
                        },
                      ),
                    ),
                    FutureBuilder<List<ClassModel>>(
                      future: accountProvider.account!.goupID == 'giaoVien'
                          ? ClassController.fetchAllClassesByYearAndTearcher(
                              year, accountProvider.account!.idAcc)
                          : ClassController.fetchAllClassesByYear(year),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SkeletonLoader(
                            builder: Column(
                              children: List.generate(
                                  2,
                                  (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          height: 60,
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

                        return Column(
                          children: classes.map((classModel) {
                            int monthKey = _getMonthKey(selectedMonth);
                            return AllConductCard(
                              classModel: classModel,
                              monthKey: monthKey,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
