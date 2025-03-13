import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/custom_snack_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';
import 'package:vnclass/web/sidebar_widget.dart'; // Import SidebarWidget

class MistakeWriteMistakePageWeb extends StatefulWidget {
  const MistakeWriteMistakePageWeb({super.key});
  static const String routeName = '/mistake_write_mistake_page_web';

  @override
  State<MistakeWriteMistakePageWeb> createState() =>
      _MistakeWriteMistakePageWebState();
}

class _MistakeWriteMistakePageWebState
    extends State<MistakeWriteMistakePageWeb> {
  String? selectedItem;
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;

  final Map<String, dynamic> menuItem = {
    'icon': Icons.warning,
    'label': 'Cập nhật vi phạm'
  }; // Sidebar chỉ có 1 mục

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toLocal().toString().split(" ")[0];
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF424242),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _saveMistakeData(
    StudentDetailModel studentDetailModel,
    MistakeModel mistakeModel,
    AccountModel accountModel,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      final classDocRef = FirebaseFirestore.instance
          .collection('CLASS')
          .doc(studentDetailModel.classID);
      final classSnapshot = await classDocRef.get();

      if (!classSnapshot.exists) {
        throw Exception('Không tìm thấy lớp!');
      }

      final data = classSnapshot.data()!;
      int numberOfMisALL = int.parse(data['_numberOfMisAll']) + 1;
      await classDocRef.update({
        '_numberOfMisAll': numberOfMisALL.toString(),
        '_numberOfMisS2':
            (DateTime.now().month >= 1 && DateTime.now().month <= 5)
                ? (int.parse(data['_numberOfMisS2']) + 1).toString()
                : data['_numberOfMisS2'],
        '_numberOfMisS1':
            (DateTime.now().month >= 9 && DateTime.now().month <= 12)
                ? (int.parse(data['_numberOfMisS1']) + 1).toString()
                : data['_numberOfMisS1'],
      });

      final time = DateTime.now();
      final formattedTime =
          '${time.second}${time.minute}${time.day}${time.month}${time.year}';
      String idStudent = studentDetailModel.id;
      final idDoc = '$idStudent+$formattedTime';

      String monthString = _dateController.text.split('-')[1];
      String monthKey = 'month${monthString.replaceFirst('0', '')}';
      String monthSave = 'Tháng ${monthString.replaceFirst('0', '')}';

      final conductDocRef =
          FirebaseFirestore.instance.collection('CONDUCT_MONTH').doc(idStudent);
      final conductSnapshot = await conductDocRef.get();

      if (!conductSnapshot.exists) {
        throw Exception('Không tìm thấy dữ liệu conduct!');
      }

      final conductData = conductSnapshot.data() as Map<String, dynamic>;
      final monthData = conductData['_month'] as Map<String, dynamic>;

      if (monthData.containsKey(monthKey) &&
          monthData[monthKey] is List &&
          monthData[monthKey].length >= 2) {
        int currentPoints = int.parse(monthData[monthKey][0]);
        String updatedPoints =
            (currentPoints - mistakeModel.minusPoint).toString();

        final setPointRef =
            FirebaseFirestore.instance.collection('SET_UP').doc('setPoint');
        final setPointSnapshot = await setPointRef.get();
        String conductType = '';

        if (setPointSnapshot.exists) {
          final pointsData = setPointSnapshot.data()!['points'];
          int points = int.parse(updatedPoints);
          if (points >= int.parse(pointsData['good']['from']) &&
              points <= int.parse(pointsData['good']['to'])) {
            conductType = 'Tốt';
          } else if (points >= int.parse(pointsData['fair']['from']) &&
              points <= int.parse(pointsData['fair']['to'])) {
            conductType = 'Khá';
          } else if (points >= int.parse(pointsData['pass']['from']) &&
              points <= int.parse(pointsData['pass']['to'])) {
            conductType = 'Đạt';
          } else {
            conductType = 'Chưa Đạt';
          }
        }

        monthData[monthKey][0] = updatedPoints;
        monthData[monthKey][1] = conductType;
        await conductDocRef.update({'_month': monthData});

        await FirebaseFirestore.instance
            .collection('MISTAKE_MONTH')
            .doc(idDoc)
            .set({
          'ACC_id': accountModel.idAcc,
          'ACC_name': accountModel.accName,
          'M_id': mistakeModel.idMistake,
          'M_name': mistakeModel.nameMistake,
          'STD_id': idStudent,
          '_id': idDoc,
          '_month': monthSave,
          '_subject': selectedItem ?? '',
          '_time': _dateController.text,
        });

        final updatedConductSnapshot = await conductDocRef.get();
        if (!updatedConductSnapshot.exists) {
          throw Exception('Không thể lấy dữ liệu CONDUCT_MONTH mới');
        }
        final allConductData =
            updatedConductSnapshot.data()!['_month'] as Map<String, dynamic>;

        Map<String, int> term1Count = {
          'Tốt': 0,
          'Khá': 0,
          'Đạt': 0,
          'Chưa Đạt': 0
        };
        for (int i = 9; i <= 12; i++) {
          String key = 'month$i';
          if (allConductData.containsKey(key) &&
              allConductData[key].length >= 2) {
            term1Count[allConductData[key][1] as String] =
                (term1Count[allConductData[key][1] as String] ?? 0) + 1;
          }
        }

        Map<String, int> term2Count = {
          'Tốt': 0,
          'Khá': 0,
          'Đạt': 0,
          'Chưa Đạt': 0
        };
        for (int i = 1; i <= 5; i++) {
          String key = 'month$i';
          if (allConductData.containsKey(key) &&
              allConductData[key].length >= 2) {
            term2Count[allConductData[key][1] as String] =
                (term2Count[allConductData[key][1] as String] ?? 0) + 1;
          }
        }

        final setTerm1Ref =
            FirebaseFirestore.instance.collection('SET_UP').doc('setTerm1');
        final setTerm2Ref =
            FirebaseFirestore.instance.collection('SET_UP').doc('setTerm2');
        final setTerm3Ref =
            FirebaseFirestore.instance.collection('SET_UP').doc('setTerm3');

        final setTerm1Snap = await setTerm1Ref.get();
        final setTerm2Snap = await setTerm2Ref.get();
        final setTerm3Snap = await setTerm3Ref.get();

        String conductTerm1 = setTerm1Snap.exists
            ? _determineConduct(setTerm1Snap.data()!['conditions'], term1Count)
            : 'Chưa Đạt';
        String conductTerm2 = setTerm2Snap.exists
            ? _determineConduct(setTerm2Snap.data()!['conditions'], term2Count)
            : 'Chưa Đạt';
        String conductAllYear = setTerm3Snap.exists
            ? _determineAllYear(
                setTerm3Snap.data()!['conditions'], conductTerm1, conductTerm2)
            : 'Chưa Đạt';

        await FirebaseFirestore.instance
            .collection('STUDENT_DETAIL')
            .doc(idStudent)
            .update({
          '_conductAllYear': conductAllYear,
          '_conductTerm1': conductTerm1,
          '_conductTerm2': conductTerm2,
        });

        String accid = await StudentController.fetchAccountByID(
            studentDetailModel.idStudent);
        List<String> deviceTokens = await AccountController.fetchTokens(accid);
        await NotificationService.sendNotification(
          accid,
          deviceTokens,
          'Thông báo vi phạm',
          'Bạn có 1 vi phạm mới: ${mistakeModel.nameMistake}',
        );
        await NotificationController.createNotification(
          accid,
          'Thông báo vi phạm',
          'Bạn có 1 vi phạm mới: ${mistakeModel.nameMistake}',
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Không tìm thấy dữ liệu tháng!');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'Lỗi: $e',
          isError: true,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _determineConduct(
      Map<String, dynamic> conditions, Map<String, int> termCount) {
    for (var type in ['good', 'fair', 'pass', 'fail']) {
      for (var condition in conditions[type]) {
        if (termCount['Tốt'] == int.parse(condition['good']) &&
            termCount['Khá'] == int.parse(condition['fair']) &&
            termCount['Đạt'] == int.parse(condition['pass']) &&
            termCount['Chưa Đạt'] == int.parse(condition['fail'])) {
          return type == 'good'
              ? 'Tốt'
              : type == 'fair'
                  ? 'Khá'
                  : type == 'pass'
                      ? 'Đạt'
                      : 'Chưa Đạt';
        }
      }
    }
    return 'Chưa Đạt';
  }

  String _determineAllYear(
      Map<String, dynamic> conditions, String term1, String term2) {
    for (var type in ['good', 'fair', 'pass', 'fail']) {
      for (var condition in conditions[type]) {
        if (condition['hki'] == term1 && condition['hkii'] == term2) {
          return type == 'good'
              ? 'Tốt'
              : type == 'fair'
                  ? 'Khá'
                  : type == 'pass'
                      ? 'Đạt'
                      : 'Chưa Đạt';
        }
      }
    }
    return 'Chưa Đạt';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PackageData;
    StudentDetailModel studentDetailModel = args.agr3;
    MistakeModel mistakeModel = args.agr2;
    AccountModel accountModel = args.agr4;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Sidebar sử dụng SidebarWidget
          SidebarWidget(
            appTitle: 'VNCLASS',
            menuItem: menuItem,
            isSelected: true,
            onItemTap: () {
              print('Đã nhấn: ${menuItem['label']}');
            },
          ),
          // Nội dung chính
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 250,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E3A8A).withOpacity(0.9),
                            const Color(0xFF3B82F6).withOpacity(0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Cập nhật vi phạm - ${studentDetailModel.nameStudent}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nội dung
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tên vi phạm',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    mistakeModel.nameMistake,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE53935),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Môn học',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Chọn môn học',
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE0E0E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF1976D2), width: 2),
                                    ),
                                  ),
                                  value: selectedItem,
                                  items: ['Lớp 10', 'Lớp 11', 'Lớp 12']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedItem = newValue;
                                    });
                                  },
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Thời gian vi phạm',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _dateController,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Chọn ngày',
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    suffixIcon: const Icon(
                                      FontAwesomeIcons.calendar,
                                      color: Color(0xFF78909C),
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE0E0E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF1976D2), width: 2),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: _selectDate,
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => _saveMistakeData(
                                              studentDetailModel,
                                              mistakeModel,
                                              accountModel),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF43A047),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Lưu',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE53935),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text(
                                        'Thoát',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}
