import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/search_bar.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/conduct/widget/all_conduct_card.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/web/conduct/conduct_detail_view_web.dart';

class ConductViewWeb extends StatefulWidget {
  const ConductViewWeb({super.key});

  static String routeName = 'conduct_view_web';
  @override
  State<ConductViewWeb> createState() => _ConductViewWebState();
}

class _ConductViewWebState extends State<ConductViewWeb> {
  String selectedMonth = '';
  String selectedTerm = '';
  String selectedYear = '';
  late AccountProvider accountProvider;
  ClassModel? selectedClass;
  List<ClassModel> _allClasses = [];
  List<ClassModel> _filteredClasses = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  List<String> validMonths = [];

  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    // Determine the initial term and month based on the current month
    String currentMonth = Getmonthnow.currentMonth();
    selectedTerm = _getTermFromMonth(currentMonth);
    validMonths = _getValidMonths(selectedTerm);

    // Set selectedMonth to the current month if it's valid, otherwise, use the first valid month
    selectedMonth = validMonths.contains(currentMonth)
        ? currentMonth
        : (validMonths.isNotEmpty ? validMonths.first : '');

    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    selectedYear =
        yearProvider.years.isNotEmpty ? yearProvider.years.first : '';

    _loadClasses();
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
        'Tất cả tháng HK2',
        'Tháng 1',
        'Tháng 2',
        'Tháng 3',
        'Tháng 4',
        'Tháng 5'
      ];
    } else if (term == 'Học kỳ 1') {
      return [
        'Tất cả tháng HK1',
        'Tháng 9',
        'Tháng 10',
        'Tháng 11',
        'Tháng 12'
      ];
    }
    return ['Cả năm'];
  }

  int _getMonthKey(String selectedMonth) {
    if (selectedMonth.contains('Tất cả tháng HK1')) {
      return 100;
    } else if (selectedMonth.contains('Tất cả tháng HK2')) {
      return 200;
    } else if (selectedMonth.contains('Cả năm')) {
      return 300;
    } else {
      return Getmonthnow.getMonthNumber(selectedMonth);
    }
  }

  void _filterClasses(String query) {
    setState(() {
      _filteredClasses = _allClasses.where((classItem) {
        return classItem.className!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true; // Start loading classes
    });
    var fetchedClasses = await ClassController.fetchAllClasses();
    if (accountProvider.account!.goupID == 'giaoVien' &&
        selectedYear.isNotEmpty) {
      fetchedClasses = await ClassController.fetchAllClassesByYearAndTearcher(
          selectedYear, accountProvider.account!.idAcc);
    } else if (accountProvider.account!.goupID == 'banGH' &&
        selectedYear.isNotEmpty) {
      fetchedClasses =
          await ClassController.fetchAllClassesByYear(selectedYear);
    } else {
      fetchedClasses = await ClassController.fetchAllClassesByTearcherID(
          accountProvider.account!.idAcc);
    }
    setState(() {
      _allClasses = fetchedClasses;
      _filteredClasses =
          _allClasses; // Set filtered classes to all classes initially
      _isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 1;
    final yearProvider = Provider.of<YearProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(paddingValue * 0.01),
            child: Text(
              'Danh sách hạnh kiểm các lớp:',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(paddingValue * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: DropMenuWidget<String>(
                              items: ['Học kỳ 1', 'Học kỳ 2', 'Cả năm'],
                              hintText: 'Học kỳ',
                              selectedItem: selectedTerm,
                              borderColor: Color(0xFFD3D3D3),
                              onChanged: (termValue) {
                                // Call _updateTermAndMonths to update both term and months
                                _updateTermAndMonths(termValue!);
                              },
                            ),
                          ),
                          SizedBox(width: paddingValue * 0.02),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: DropMenuWidget(
                              items: validMonths,
                              key: ValueKey(validMonths),
                              selectedItem: selectedMonth,
                              borderColor: Color(0xFFD3D3D3),
                              hintText: 'Tháng',
                              onChanged: (value) {
                                setState(() {
                                  selectedMonth = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: paddingValue * 0.02),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: DropMenuWidget(
                              items: yearProvider.years,
                              selectedItem: selectedYear,
                              borderColor: Color(0xFFD3D3D3),
                              hintText: 'Niên Khóa',
                              onChanged: (value) {
                                setState(() {
                                  selectedYear = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: paddingValue * 0.02),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterClasses,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF2F4F4F)),
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm...',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF696969),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(Icons.search,
                                        color: Color(0xFF1E90FF), size: 24),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD3D3D3), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFF1E90FF), width: 2.0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _filteredClasses
                                  .isEmpty // Check if _filteredClasses is empty
                              ? Center(child: Text('Không có lớp học'))
                              : SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 16.0,
                                    runSpacing: 16.0,
                                    children:
                                        _filteredClasses.map((classModel) {
                                      int monthKey =
                                          _getMonthKey(selectedMonth);
                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: AllConductCard(
                                          classModel: classModel,
                                          monthKey: monthKey,
                                          onSelect: (selectedClassModel) {
                                            setState(() {
                                              // Cập nhật lớp học đã chọn
                                              selectedClass =
                                                  selectedClassModel;
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 1,
        child: selectedClass != null
            ? ConductDetailViewWeb(
                classID: selectedClass!.id,
                className: selectedClass!.className,
                monthKey: _getMonthKey(selectedMonth),
              )
            : Center(child: Text('Chưa chọn lớp học')),
      ),
    );
  }
}
