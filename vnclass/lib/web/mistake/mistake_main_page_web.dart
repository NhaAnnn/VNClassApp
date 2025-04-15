import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/permission_provider.dart';
import 'package:vnclass/modules/main_home/controller/student_detail_provider.dart';
import 'package:vnclass/modules/main_home/controller/teacher_provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/mistake/controllers/mistake_repository.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/web/mistake/item_class_mistake_student_web.dart';
import 'package:vnclass/web/mistake/item_class_mistake_web.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MistakeMainPageWeb extends StatefulWidget {
  const MistakeMainPageWeb({super.key});
  static const String routeName = '/mistake_main_page_web';

  @override
  State<MistakeMainPageWeb> createState() => _MistakeMainPageWebState();
}

class _MistakeMainPageWebState extends State<MistakeMainPageWeb> {
  late Future<List<ClassMistakeModel>> futureMistakeClass;
  final MistakeRepository mistakeRepository = MistakeRepository();
  String? selectedYear;
  String? selectedHocKy;
  String currentClassFilter = '10';
  List<ClassMistakeModel> allClasses = [];
  List<ClassMistakeModel> filteredClasses = [];

  bool isViewingClasses = true;
  List<StudentDetailModel> allStudents = [];
  List<StudentDetailModel> filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadClasses();
    selectedMonth = 'Tháng ${DateTime.now().month}';
    _loadStudents(selectedMonth!.replaceFirst('Tháng ', ''));
  }

  void _initializeData() {
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    selectedHocKy = DateTime.now().month >= 9 && DateTime.now().month <= 12
        ? 'Học kỳ 1'
        : 'Học kỳ 2';
    // selectedYear = yearProvider.years.first; // Mặc định là năm đầu tiên
    futureMistakeClass = mistakeRepository.fetchMistakeClasses('CLASS');
  }

  // Future<void> _loadClasses() async {
  //   try {
  //     final classes = await mistakeRepository.fetchMistakeClasses('CLASS');
  //     setState(() {
  //       allClasses = classes;
  //       filteredClasses = allClasses.where((classItem) {
  //         return classItem.className.startsWith(currentClassFilter) &&
  //             (selectedYear == null || classItem.academicYear == selectedYear);
  //       }).toList();
  //     });
  //   } catch (e) {
  //     print('Lỗi khi tải danh sách lớp: $e');
  //   }
  // }
  Future<void> _loadClasses() async {
    try {
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      final account = accountProvider.account;
      List<ClassMistakeModel> classes;

      if (account?.goupID == 'banGH') {
        // Ban giám hiệu: Load tất cả lớp
        classes = await mistakeRepository.fetchMistakeClasses('CLASS');
      } else if (account?.goupID == 'giaoVien') {
        // Giáo viên: Tìm lớp có T_id khớp với account.idAcc
        final querySnapshot = await FirebaseFirestore.instance
            .collection('CLASS')
            .where('T_id', isEqualTo: account?.idAcc)
            .get();
        classes = querySnapshot.docs
            .map((doc) => ClassMistakeModel.fromFirestore(doc))
            .toList();
      } else {
        // Trường hợp khác (ví dụ: học sinh), không load lớp
        classes = [];
      }

      setState(() {
        allClasses = classes;
        filteredClasses = allClasses.where((classItem) {
          final matchesYear =
              selectedYear == null || classItem.academicYear == selectedYear;
          // Chỉ áp dụng bộ lọc lớp (10, 11, 12) cho ban giám hiệu
          final matchesClass = account?.goupID == 'banGH'
              ? classItem.className.startsWith(currentClassFilter)
              : true;
          return matchesYear && matchesClass;
        }).toList();
      });
    } catch (e) {
      print('Lỗi khi tải danh sách lớp: $e');
      setState(() {
        allClasses = [];
        filteredClasses = [];
      });
    }
  }

  Future<void> _loadStudents(String month) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('STUDENT_DETAIL').get();
      print('Số lượng tài liệu trong STUDENT_DETAIL: ${snapshot.docs.length}');
      if (snapshot.docs.isEmpty) {
        print('Không có tài liệu nào trong STUDENT_DETAIL');
      }
      final studentsFuture = snapshot.docs.map((doc) async {
        try {
          print('Đang xử lý tài liệu: ${doc.id}');
          return await StudentDetailModel.fromFirestore(doc, month);
        } catch (e) {
          print('Lỗi khi xử lý tài liệu ${doc.id}: $e, bỏ qua...');
          return null;
        }
      }).toList();

      final students = await Future.wait(studentsFuture);
      setState(() {
        allStudents = students
            .where((student) => student != null)
            .cast<StudentDetailModel>()
            .toList();
        filteredStudents = allStudents;
        print('Số lượng học sinh tải được: ${allStudents.length}');
      });
    } catch (e) {
      print('Lỗi khi tải danh sách học sinh: $e');
    }
  }

  void _filterData(String query) {
    setState(() {
      searchQuery = query;
      if (isViewingClasses) {
        filteredClasses = allClasses.where((classItem) {
          final lowerQuery = query.toLowerCase();
          return classItem.className.toLowerCase().contains(lowerQuery) ||
              classItem.idClass.toLowerCase().contains(lowerQuery);
        }).toList();
      } else {
        filteredStudents = allStudents.where((student) {
          final lowerQuery = query.toLowerCase();
          return student.nameStudent.toLowerCase().contains(lowerQuery) ||
              student.idStudent.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  void updateClass(String classFilter) {
    setState(() {
      currentClassFilter = classFilter;
      _loadClasses();
    });
  }

  Widget _buildTabButton(String title, String filter) {
    return GestureDetector(
      onTap: () => updateClass(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: currentClassFilter == filter
              ? const Color(0xFF1E3A8A)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: currentClassFilter == filter
                ? Colors.white
                : const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Xây dựng header cho danh sách học sinh
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeaderText('Mã HS')),
          Expanded(flex: 5, child: _buildHeaderText('Họ và Tên')),
          Expanded(flex: 1, child: _buildHeaderText('Lần VP')),
          Expanded(flex: 1, child: _buildHeaderText('Xem')),
          Expanded(flex: 1, child: _buildHeaderText('Sửa')),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.grey.shade800,
      ),
    );
  }

  // Xây dựng danh sách học sinh dạng dọc
  Widget buildStudentGrid() {
    if (filteredStudents.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(), // Thêm header
          Expanded(
            child: ListView.separated(
              itemCount: filteredStudents.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            student.idStudent,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            student.nameStudent,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              student.numberOfErrors,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0288D1).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(FontAwesomeIcons.eye,
                                  size: 18, color: Color(0xFF0288D1)),
                            ),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/mistake_view_mistake_page_web',
                                arguments: {
                                  'studentDetailModel': student,
                                  'month': selectedMonth,
                                },
                              );
                              _loadStudents(
                                  selectedMonth!.replaceFirst('Tháng ', ''));
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF2E7D32).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(FontAwesomeIcons.pen,
                                  size: 18, color: Color(0xFF2E7D32)),
                            ),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/mistake_type_mistake_page_web',
                                arguments: student,
                              );
                              _loadStudents(
                                  selectedMonth!.replaceFirst('Tháng ', ''));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGridView(String classFilter) {
    if (filteredClasses.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredClasses.length,
      itemBuilder: (context, index) {
        return ItemClassModelsWeb(
          classMistakeModel: filteredClasses[index],
          hocKy: selectedHocKy,
          onRefresh: _loadClasses,
        );
      },
    );
  }

  List<String> getMonthList() {
    return [
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
      'Tháng 12'
    ];
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;
    final String? idClass = account!.goupID == 'hocSinh'
        ? Provider.of<StudentDetailProvider>(context).classIdST
        : account.goupID == 'giaoVien'
            ? Provider.of<TeacherProvider>(context).classIdTeacher
            : null;
    final List<String> pers =
        Provider.of<PermissionProvider>(context).permission;
    final bool hasFullSchoolPermission =
        pers.contains('Cập nhật vi phạm học sinh toàn trường');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cập Nhật Vi Phạm',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (account.goupID == 'banGH' ||
                                hasFullSchoolPermission) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildTabButton('Lớp 10', '10'),
                                    const SizedBox(width: 8),
                                    _buildTabButton('Lớp 11', '11'),
                                    const SizedBox(width: 8),
                                    _buildTabButton('Lớp 12', '12'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Học kỳ',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF1E3A8A)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD3D3D3)),
                                  ),
                                ),
                                value: selectedHocKy,
                                items: ['Học kỳ 1', 'Học kỳ 2', 'Cả năm']
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedHocKy = value;
                                    _loadClasses();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Năm học',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF1E3A8A)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD3D3D3)),
                                  ),
                                ),
                                value: selectedYear,
                                items: yearProvider.years
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (account.goupID == 'banGH' ||
                                        hasFullSchoolPermission)
                                    ? (value) {
                                        setState(() {
                                          selectedYear = value;
                                          _loadClasses();
                                        });
                                      }
                                    : null,
                                disabledHint: Text(selectedYear ?? 'Năm học'),
                              ),
                            ),
                            if (account.goupID == 'banGH' ||
                                hasFullSchoolPermission) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _filterData,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF2F4F4F)),
                                  decoration: InputDecoration(
                                    hintText: 'Tìm kiếm...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF696969),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
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
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (account.goupID == 'banGH' ||
                            hasFullSchoolPermission) ...[
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    setState(() => isViewingClasses = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isViewingClasses
                                      ? const Color(0xFF1E3A8A)
                                      : Colors.grey,
                                ),
                                child: const Text('Xem lớp',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    setState(() => isViewingClasses = false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !isViewingClasses
                                      ? const Color(0xFF1E3A8A)
                                      : Colors.grey,
                                ),
                                child: const Text('Xem học sinh',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (!isViewingClasses) ...[
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Tháng',
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
                                    value: selectedMonth,
                                    items: getMonthList()
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMonth = value;
                                        _loadStudents(selectedMonth!
                                            .replaceFirst('Tháng ', ''));
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                        Expanded(
                          child: isViewingClasses
                              ? buildGridView(currentClassFilter)
                              : buildStudentGrid(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
