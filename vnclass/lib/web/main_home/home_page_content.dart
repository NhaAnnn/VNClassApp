import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
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
  String selectedTerm = 'Học kỳ 1';
  String? selectedYear; // Biến để lưu năm học được chọn

  // Dữ liệu giả lập
  final Map<String, int> attendanceStats = {
    'Jan': 50000,
    'Feb': 60000,
    'Mar': 55000,
    'Apr': 52000,
    'Aug': 58000,
    'Sep': 59000,
    'Nov': 54000,
    'Dec': 53000,
  };

  final List<Map<String, dynamic>> leaveApplications = [
    {'name': 'Dawash King', 'date': '29-03-2024', 'status': 'Approved'},
    {'name': 'Musad Rana', 'date': '29-03-2024', 'status': 'Approved'},
    {'name': 'Jalil Hossain', 'date': '29-03-2024', 'status': 'Pending'},
  ];

  final List<Map<String, dynamic>> notices = [
    {'title': 'Get ready for meeting at 6', 'date': '29-03-2024'},
    {'title': 'Dashboard updated', 'date': '29-03-2024'},
  ];

  final List<Map<String, dynamic>> recruitment = [
    {'name': 'Noman Khan', 'status': 'Recruited'},
    {'name': 'Aslam Islam', 'status': 'Recruited'},
    {'name': 'Musad Rana', 'status': 'Recruited'},
  ];

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
            selectedYear = yearProvider.years[0]; // Chọn năm đầu tiên mặc định
          });
        }
      });
    } else {
      setState(() {
        selectedYear = yearProvider.years[0]; // Chọn năm đầu tiên mặc định
      });
    }
  }

  // Phương thức để lấy số lượng từ Firestore (xử lý song song)
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

  // Lấy dữ liệu conduct từ STUDENT_DETAIL
  Future<Map<String, int>> _fetchConductStats(String year, String term) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('STUDENT_DETAIL').get();
    Map<String, int> conductCounts = {
      'Tốt': 0,
      'Khá': 0,
      'Đạt': 0,
      'Chưa Đạt': 0
    };

    print('Bắt đầu xử lý _fetchConductStats với year: $year, term: $term');

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final classId = data['Class_id'] as String? ?? '';
      final last9Chars = classId.length >= 9
          ? classId.substring(classId.length - 9)
          : ''; // Lấy 9 ký tự cuối

      print('Xử lý tài liệu - Class_id: $classId, last9Chars: $last9Chars');

      if (last9Chars == year) {
        String conductField;
        switch (term) {
          case 'Học kỳ 1':
            conductField = data['_conductTerm1'] as String? ?? '';
            print('Học kỳ 1 - conductField: $conductField');
            break;
          case 'Học kỳ 2':
            conductField = data['_conductTerm2'] as String? ?? '';
            print('Học kỳ 2 - conductField: $conductField');
            break;
          case 'Cả năm':
            conductField = data['_conductAllYear'] as String? ?? '';
            print('Cả năm - conductField: $conductField');
            break;
          default:
            conductField = '';
            print('Term không hợp lệ - conductField: $conductField');
        }
        if (conductCounts.containsKey(conductField)) {
          conductCounts[conductField] = (conductCounts[conductField] ?? 0) + 1;
          print(
              'Cập nhật conductCounts[$conductField] = ${conductCounts[conductField]}');
        } else {
          print(
              'Giá trị conductField: $conductField không khớp với bất kỳ xếp loại nào');
        }
      } else {
        print('last9Chars: $last9Chars không khớp với year: $year');
      }
    }

    print('Kết thúc xử lý - conductCounts: $conductCounts');
    return conductCounts;
  }

  Widget _buildPage(String title, IconData icon, List<Widget> content) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final account = accountProvider.account;
        final showExportButton = account != null &&
            (account.goupID == 'giaoVien' || account.goupID == 'banGH');
        final yearProvider = Provider.of<YearProvider>(context);

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
              FutureBuilder<Map<String, int>>(
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
                      SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: _buildStatCard(
                          'Số lượng Vi phạm',
                          '${stats['mistakes']}',
                          Icons.warning,
                          Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
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
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Năm',
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF1E3A8A)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFD3D3D3)),
                                    ),
                                  ),
                                  value: selectedYear,
                                  items: Provider.of<YearProvider>(context,
                                          listen: false)
                                      .years
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedYear = newValue;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Học kỳ',
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF1E3A8A)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFD3D3D3)),
                                    ),
                                  ),
                                  value: selectedTerm,
                                  items: ['Học kỳ 1', 'Học kỳ 2', 'Cả năm']
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
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
                                selectedYear ??
                                    (Provider.of<YearProvider>(context,
                                                listen: false)
                                            .years
                                            .isNotEmpty
                                        ? Provider.of<YearProvider>(context,
                                                listen: false)
                                            .years[0]
                                        : '2024-2025'),
                                selectedTerm),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Lỗi: ${snapshot.error}'));
                              }
                              final conductCounts = snapshot.data ?? {};
                              final total =
                                  conductCounts.values.reduce((a, b) => a + b) +
                                      0.0;
                              final goodPercent = total > 0
                                  ? (conductCounts['Tốt'] ?? 0) / total
                                  : 0.0;
                              final fairPercent = total > 0
                                  ? (conductCounts['Khá'] ?? 0) / total
                                  : 0.0;
                              final achievedPercent = total > 0
                                  ? (conductCounts['Đạt'] ?? 0) / total
                                  : 0.0;
                              final notAchievedPercent = total > 0
                                  ? (conductCounts['Chưa Đạt'] ?? 0) / total
                                  : 0.0;

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
                                      animationDuration:
                                          const Duration(milliseconds: 1200),
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
                                      chartValuesOptions:
                                          const ChartValuesOptions(
                                        showChartValueBackground: true,
                                        showChartValues: true,
                                        showChartValuesInPercentage: true,
                                        chartValueStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        chartValueBackgroundColor:
                                            Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  color: Colors.blue[700],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                    'Tốt: ${(conductCounts['Tốt'] ?? 0)}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
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
                                                Text(
                                                    'Khá: ${(conductCounts['Khá'] ?? 0)}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  color: Colors.orange[700],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                    'Đạt: ${(conductCounts['Đạt'] ?? 0)}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
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
                                                        fontSize: 14,
                                                        color: Colors.grey)),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
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
                    const Text('This Daily Attendance Statistic',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        )),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: attendanceStats.entries.map((entry) {
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 150 * (entry.value / 60000),
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(
                                  '${entry.value ~/ 1000}k',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              _buildSection('Recruitment', [
                for (var rec in recruitment)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[700],
                      radius: 20,
                      child: Text(rec['name'][0],
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(rec['name'],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text(rec['status'],
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500)),
                  ),
              ]),
            ],
          ),
        );
      },
    );
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
