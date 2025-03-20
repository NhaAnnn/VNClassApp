import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/web/main_home/dialog_report_web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Widget _buildPage(String title, IconData icon, List<Widget> content) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final account = accountProvider.account;
        final showExportButton = account != null &&
            (account.goupID == 'giaoVien' || account.goupID == 'banGH');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 28, color: const Color(0xFF1E3A8A)),
                      const SizedBox(width: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  if (showExportButton)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'class') {
                            _showReportDialog(context, 'class');
                          } else if (value == 'school') {
                            _showReportDialog(context, 'school');
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'class',
                            child: Text('Xuất Báo Cáo Vi Phạm Lớp Học'),
                          ),
                          if (account.goupID == 'banGH')
                            const PopupMenuItem<String>(
                              value: 'school',
                              child: Text('Xuất Báo Cáo Vi Phạm Trường Học'),
                            ),
                        ],
                        icon: const Icon(
                          Icons.file_download,
                          size: 24,
                          color: Color(0xFF1E3A8A),
                        ),
                        tooltip: 'Xuất báo cáo',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const DashboardStatsWidget(), // Sử dụng widget tách biệt
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child:
                        const ConductStatisticsWidget(), // Sử dụng widget tách biệt
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const ViolationStatisticsWidget(), // Sử dụng widget tách biệt
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, String reportType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogReportWeb(reportType: reportType);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage('Dashboard', Icons.dashboard, []);
  }
}

//=======================================
class ViolationStatisticsWidget extends StatefulWidget {
  const ViolationStatisticsWidget({super.key});

  @override
  State<ViolationStatisticsWidget> createState() =>
      _ViolationStatisticsWidgetState();
}

class _ViolationStatisticsWidgetState extends State<ViolationStatisticsWidget> {
  String? selectedYearViolation;
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    _initializeYearProvider(yearProvider);
    _initializeSelectedMonth();
  }

  void _initializeYearProvider(YearProvider yearProvider) {
    if (yearProvider.years.isEmpty) {
      yearProvider.fetchYears().then((_) {
        if (yearProvider.years.isNotEmpty && mounted) {
          setState(() {
            selectedYearViolation = yearProvider.years[0];
          });
        }
      });
    } else {
      setState(() {
        selectedYearViolation = yearProvider.years[0];
      });
    }
  }

  void _initializeSelectedMonth() {
    final currentMonth = DateTime.now().month;
    final monthList = getMonthList();

    final defaultMonth = 'Tháng $currentMonth';

    if (monthList.contains(defaultMonth)) {
      selectedMonth = defaultMonth;
    } else {
      selectedMonth = 'Tất cả';
    }
  }

  List<String> getMonthList() {
    return [
      'Tất cả',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
  }

  Future<Map<String, int>> _fetchViolationStats(
      String year, String? month) async {
    final firestore = FirebaseFirestore.instance;

    // print('Bắt đầu _fetchViolationStats với year: $year, month: $month');

    // print('Lấy danh sách lớp từ CLASS với year: $year');
    final classSnapshot = await firestore
        .collection('CLASS')
        .where('_year', isEqualTo: year)
        .get();

    // print('Số lượng lớp tìm thấy: ${classSnapshot.docs.length}');
    if (classSnapshot.docs.isEmpty) {
      // print('Không tìm thấy lớp nào với year: $year');
      return {};
    }

    Map<String, int> violationStats = {};
    Map<String, String> classIdToName = {};

    for (var classDoc in classSnapshot.docs) {
      final classData = classDoc.data();
      final className = classData['_className'] as String? ?? 'Unknown';
      final classId = classData['_id'] as String? ?? '';
      violationStats[className] = 0;
      classIdToName[classId] = className;
      // print('Lớp: $className, Class_id: $classId');
    }

    // print('Lấy danh sách học sinh từ STUDENT_DETAIL');
    final studentSnapshots = await Future.wait(
      classIdToName.keys.map((classId) => firestore
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classId)
          .get()),
    );

    Map<String, String> studentToClassId = {};
    for (var i = 0; i < studentSnapshots.length; i++) {
      final studentSnapshot = studentSnapshots[i];
      final classId = classIdToName.keys.elementAt(i);
      final className = classIdToName[classId]!;
      // print(
      // 'Số lượng học sinh trong lớp $className: ${studentSnapshot.docs.length}');
      if (studentSnapshot.docs.isEmpty) {
        // print('Không tìm thấy học sinh nào với Class_id: $classId');
        continue;
      }

      for (var doc in studentSnapshot.docs) {
        final data = doc.data();
        final stdId = data['_id'] as String? ?? '';
        if (stdId.isNotEmpty) {
          studentToClassId[stdId] = classId;
        }
      }
    }

    List<String> studentIds = studentToClassId.keys.toList();
    // print('Danh sách STD_id: $studentIds');
    if (studentIds.isEmpty) {
      // print('Không tìm thấy học sinh nào để đếm vi phạm');
      return violationStats;
    }

    print('Lấy tất cả vi phạm từ MISTAKE_MONTH');
    Query query = firestore.collection('MISTAKE_MONTH').where('STD_id',
        whereIn: studentIds); // Sử dụng whereIn để lấy tất cả vi phạm

    if (month != null && month != 'Tất cả') {
      query = query.where('_month', isEqualTo: month);
      // print('Lọc vi phạm theo tháng: $month');
    }

    final mistakeSnapshot = await query.get();
    // print('Tổng số lượng vi phạm tìm thấy: ${mistakeSnapshot.docs.length}');

    for (var doc in mistakeSnapshot.docs) {
      final mistakeData = doc.data() as Map<String, dynamic>?;
      if (mistakeData != null) {
        final stdId = mistakeData['STD_id'] as String?;
        if (stdId != null && studentToClassId.containsKey(stdId)) {
          final classId = studentToClassId[stdId]!;
          final className = classIdToName[classId]!;
          violationStats[className] = (violationStats[className] ?? 0) + 1;
        }

        // Log chi tiết vi phạm
        // print(
        // ' - M_id: ${mistakeData['M_id'] ?? 'N/A'}, M_name: ${mistakeData['M_name'] ?? 'N/A'}, _month: ${mistakeData['_month'] ?? 'N/A'}');
      } else {
        // print(' - Dữ liệu vi phạm là null');
      }
    }

    // print('Kết quả violationStats: $violationStats');
    return violationStats;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0x1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Violation Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Consumer<YearProvider>(
                  builder: (context, yearProvider, child) {
                    final years = yearProvider.years.isNotEmpty
                        ? yearProvider.years
                        : ['2024-2025'];
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Năm',
                        labelStyle: const TextStyle(color: Color(0xFF1E3A8A)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFD3D3D3)),
                        ),
                      ),
                      value: selectedYearViolation ?? years[0],
                      items: years
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYearViolation = newValue;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tháng',
                    labelStyle: const TextStyle(color: Color(0xFF1E3A8A)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                    ),
                  ),
                  value: selectedMonth,
                  items: getMonthList()
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMonth = newValue;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: _fetchViolationStats(
                selectedYearViolation ??
                    (Provider.of<YearProvider>(context, listen: false)
                            .years
                            .isNotEmpty
                        ? Provider.of<YearProvider>(context, listen: false)
                            .years[0]
                        : '2024-2025'),
                selectedMonth),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              final violationStats = snapshot.data ?? {};
              if (violationStats.isEmpty) {
                return const Center(child: Text('Không có dữ liệu vi phạm'));
              }

              final maxViolations = violationStats.values.isNotEmpty
                  ? violationStats.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble()
                  : 1.0;

              return Container(
                height: 180,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: violationStats.entries.map((entry) {
                    final normalizedHeight = maxViolations > 0
                        ? (entry.value / maxViolations) * 120
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: normalizedHeight,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================
class ConductStatisticsWidget extends StatefulWidget {
  const ConductStatisticsWidget({super.key});

  @override
  State<ConductStatisticsWidget> createState() =>
      _ConductStatisticsWidgetState();
}

class _ConductStatisticsWidgetState extends State<ConductStatisticsWidget> {
  String selectedTerm = 'Học kỳ 1';
  String? selectedYearConduct; // Biến riêng cho Conduct Statistics

  @override
  void initState() {
    super.initState();
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    _initializeYearProvider(yearProvider);
  }

  void _initializeYearProvider(YearProvider yearProvider) {
    if (yearProvider.years.isEmpty) {
      yearProvider.fetchYears().then((_) {
        if (yearProvider.years.isNotEmpty && mounted) {
          setState(() {
            selectedYearConduct = yearProvider.years[0];
          });
        }
      });
    } else {
      setState(() {
        selectedYearConduct = yearProvider.years[0];
      });
    }
  }

  Future<Map<String, int>> _fetchConductStats(String year, String term) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('STUDENT_DETAIL').get();
    Map<String, int> conductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final classId = data['Class_id'] as String? ?? '';
      final last9Chars =
          classId.length >= 9 ? classId.substring(classId.length - 9) : '';

      if (last9Chars == year) {
        String conductField;
        switch (term) {
          case 'Học kỳ 1':
            conductField = data['_conductTerm1'] as String? ?? '';
            break;
          case 'Học kỳ 2':
            conductField = data['_conductTerm2'] as String? ?? '';
            break;
          case 'Cả năm':
            conductField = data['_conductAllYear'] as String? ?? '';
            break;
          default:
            conductField = '';
        }
        if (conductCounts.containsKey(conductField)) {
          conductCounts[conductField] = (conductCounts[conductField] ?? 0) + 1;
        }
      }
    }

    return conductCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0x1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thống kê hạnh kiểm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Consumer<YearProvider>(
                  builder: (context, yearProvider, child) {
                    final years = yearProvider.years.isNotEmpty
                        ? yearProvider.years
                        : ['2024-2025'];
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Năm',
                        labelStyle: const TextStyle(color: Color(0xFF1E3A8A)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFD3D3D3)),
                        ),
                      ),
                      value: selectedYearConduct ?? years[0],
                      items: years
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYearConduct = newValue;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Học kỳ',
                    labelStyle: const TextStyle(color: Color(0xFF1E3A8A)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
                    ),
                  ),
                  value: selectedTerm,
                  items: ['Học kỳ 1', 'Học kỳ 2', 'Cả năm']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTerm = newValue ?? 'Học kỳ 1';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: _fetchConductStats(
                selectedYearConduct ??
                    (Provider.of<YearProvider>(context, listen: false)
                            .years
                            .isNotEmpty
                        ? Provider.of<YearProvider>(context, listen: false)
                            .years[0]
                        : '2024-2025'),
                selectedTerm),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              final conductCounts = snapshot.data ?? {};
              final total = conductCounts.values.reduce((a, b) => a + b) + 0.0;
              final goodPercent =
                  total > 0 ? (conductCounts['Tốt'] ?? 0) / total : 0.0;
              final fairPercent =
                  total > 0 ? (conductCounts['Khá'] ?? 0) / total : 0.0;
              final achievedPercent =
                  total > 0 ? (conductCounts['Đạt'] ?? 0) / total : 0.0;
              final notAchievedPercent =
                  total > 0 ? (conductCounts['Chưa Đạt'] ?? 0) / total : 0.0;

              Map<String, double> dataMap = {
                'Tốt': goodPercent * 100,
                'Khá': fairPercent * 100,
                'Đạt': achievedPercent * 100,
                'Chưa Đạt': notAchievedPercent * 100,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      dataMap: dataMap,
                      animationDuration: const Duration(milliseconds: 1200),
                      chartLegendSpacing: 40,
                      chartRadius: 120,
                      colorList: [
                        Colors.blue[700]!,
                        Colors.green[700]!,
                        Colors.orange[700]!,
                        Colors.red[700]!,
                      ],
                      initialAngleInDegree: 0,
                      chartType: ChartType.ring,
                      ringStrokeWidth: 40,
                      legendOptions: const LegendOptions(
                        showLegendsInRow: true,
                        legendPosition: LegendPosition.bottom,
                        showLegends: true,
                        legendTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        chartValueStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        chartValueBackgroundColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text('Tốt: ${(conductCounts['Tốt'] ?? 0)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 8),
                                Text('Khá: ${(conductCounts['Khá'] ?? 0)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 8),
                                Text('Đạt: ${(conductCounts['Đạt'] ?? 0)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    'Chưa Đạt: ${(conductCounts['Chưa Đạt'] ?? 0)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardStatsWidget extends StatefulWidget {
  const DashboardStatsWidget({super.key});

  @override
  State<DashboardStatsWidget> createState() => _DashboardStatsWidgetState();
}

class _DashboardStatsWidgetState extends State<DashboardStatsWidget> {
  Future<Map<String, int>> _fetchDashboardStats() async {
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore.collection('STUDENT').get(),
      firestore.collection('MISTAKE_MONTH').get(),
      firestore.collection('ACCOUNT').get(),
    ]);

    final studentCount = results[0].docs.length;
    final mistakeCount = results[1].docs.length;
    final accountCount = results[2].docs.length;

    return {
      'students': studentCount,
      'mistakes': mistakeCount,
      'accounts': accountCount,
    };
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor,
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final stats = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _buildStatCard(
                'Số lượng Học sinh',
                '${stats['students']}',
                Icons.people,
                Colors.red,
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: _buildStatCard(
                'Số lượng Vi phạm',
                '${stats['mistakes']}',
                Icons.warning,
                Colors.green,
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: _buildStatCard(
                'Số lượng Tài khoản',
                '${stats['accounts']}',
                Icons.account_circle,
                Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}
