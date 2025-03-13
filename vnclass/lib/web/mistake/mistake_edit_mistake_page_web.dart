import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/custom_snack_bar.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';
import 'package:vnclass/web/sidebar_widget.dart';

class MistakeEditMistakePageWeb extends StatefulWidget {
  const MistakeEditMistakePageWeb({super.key});
  static const String routeName = '/mistake_edit_mistake_page_web';

  @override
  State<MistakeEditMistakePageWeb> createState() =>
      _MistakeEditMistakePageWebState();
}

class _MistakeEditMistakePageWebState extends State<MistakeEditMistakePageWeb> {
  String? selectedItem;
  String? oldMonth;
  bool isLoading = false;
  final TextEditingController _dateController = TextEditingController();

  final Map<String, dynamic> menuItem = {
    'icon': FontAwesomeIcons.pen,
    'label': 'Chỉnh sửa vi phạm'
  }; // Sidebar chỉ có 1 mục

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as PackageData;
      EditMistakeModel editMistakeModel = args.agrReq;

      _dateController.text = editMistakeModel.mm_time;
      oldMonth = _dateController.text.split('-')[1].replaceFirst('0', '');
      selectedItem = editMistakeModel.mm_subject.isNotEmpty
          ? editMistakeModel.mm_subject
          : null;

      setState(() {});
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> updateMistakeData(
    EditMistakeModel editMistakeModel,
    StudentDetailModel studentDetailModel,
    AccountModel accountModel,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      String idStudent = studentDetailModel.id;
      String monthString =
          _dateController.text.split('-')[1].replaceFirst('0', '');
      String monthSave = 'Tháng $monthString';
      String monthKey = 'month$monthString';
      String oldMonthKey = 'month$oldMonth';

      final conductDocRef =
          FirebaseFirestore.instance.collection('CONDUCT_MONTH').doc(idStudent);
      final conductSnapshot = await conductDocRef.get();

      if (!conductSnapshot.exists) {
        throw Exception('Không tìm thấy dữ liệu CONDUCT_MONTH');
      }

      final conductData = conductSnapshot.data() as Map<String, dynamic>;
      final monthData = conductData['_month'] as Map<String, dynamic>;

      final setPointRef =
          FirebaseFirestore.instance.collection('SET_UP').doc('setPoint');
      final setPointSnapshot = await setPointRef.get();
      if (!setPointSnapshot.exists) {
        throw Exception('Không tìm thấy dữ liệu setPoint');
      }
      final pointsData = setPointSnapshot.data()!['points'];

      if (oldMonth != monthString) {
        if (monthData.containsKey(oldMonthKey) &&
            monthData[oldMonthKey] is List &&
            monthData[oldMonthKey].length >= 2) {
          int currentOldPoints =
              int.parse(monthData[oldMonthKey][0].toString());
          int updatedOldPoints =
              currentOldPoints + (editMistakeModel.mistake?.minusPoint ?? 0);
          String oldConductType =
              _determineConductType(updatedOldPoints, pointsData);
          monthData[oldMonthKey] = [
            updatedOldPoints.toString(),
            oldConductType
          ];
        }

        if (monthData.containsKey(monthKey) &&
            monthData[monthKey] is List &&
            monthData[monthKey].length >= 2) {
          int currentNewPoints = int.parse(monthData[monthKey][0].toString());
          int updatedNewPoints =
              currentNewPoints - (editMistakeModel.mistake?.minusPoint ?? 0);
          String newConductType =
              _determineConductType(updatedNewPoints, pointsData);
          monthData[monthKey] = [updatedNewPoints.toString(), newConductType];
        }
      } else {
        if (monthData.containsKey(monthKey) &&
            monthData[monthKey] is List &&
            monthData[monthKey].length >= 2) {
          int currentPoints = int.parse(monthData[monthKey][0].toString());
          int updatedPoints = currentPoints;
          String conductType = _determineConductType(updatedPoints, pointsData);
          monthData[monthKey] = [updatedPoints.toString(), conductType];
        }
      }

      await conductDocRef.update({'_month': monthData});

      await FirebaseFirestore.instance
          .collection('MISTAKE_MONTH')
          .doc(editMistakeModel.mm_id)
          .update({
        'ACC_id': accountModel.idAcc,
        'ACC_name': accountModel.accName,
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

      String accid = await NotificationController.fetchAccIdFromStudentDetail(
          studentDetailModel.id);
      List<String> deviceTokens = await AccountController.fetchTokens(accid);
      await NotificationService.sendNotification(
        accid,
        deviceTokens,
        'Thông báo vi phạm',
        'Một vi phạm của bạn đã được chỉnh sửa: Vi phạm ${editMistakeModel.m_name} vào ${_dateController.text}',
      );
      await NotificationController.createNotification(
        accid,
        'Thông báo vi phạm',
        'Một vi phạm của bạn đã được chỉnh sửa: Vi phạm ${editMistakeModel.m_name} vào ${_dateController.text}',
      );

      if (mounted) {
        Navigator.pop(context, true);
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

  String _determineConductType(int points, Map<String, dynamic> pointsData) {
    if (points >= int.parse(pointsData['good']['from']) &&
        points <= int.parse(pointsData['good']['to'])) {
      return 'Tốt';
    } else if (points >= int.parse(pointsData['fair']['from']) &&
        points <= int.parse(pointsData['fair']['to'])) {
      return 'Khá';
    } else if (points >= int.parse(pointsData['pass']['from']) &&
        points <= int.parse(pointsData['pass']['to'])) {
      return 'Đạt';
    }
    return 'Chưa Đạt';
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
    EditMistakeModel editMistakeModel = args.agrReq;
    StudentDetailModel studentDetailModel = args.agr2;
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Sidebar
          SidebarWidget(
            appTitle: 'Ứng dụng của tôi',
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
                              'Chỉnh sửa vi phạm của ${studentDetailModel.nameStudent}',
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
                    // Form chỉnh sửa
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên vi phạm
                                Text(
                                  'Tên vi phạm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.redAccent.shade100),
                                  ),
                                  child: Text(
                                    editMistakeModel.m_name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Môn học
                                Text(
                                  'Môn học',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Chọn môn học',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 2),
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
                                const SizedBox(height: 20),
                                // Thời gian vi phạm
                                Text(
                                  'Thời gian vi phạm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _dateController,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Chọn ngày',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    suffixIcon: const Icon(
                                      FontAwesomeIcons.calendar,
                                      color: Colors.blueGrey,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 2),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: _selectDate,
                                ),
                                const SizedBox(height: 32),
                                // Nút hành động
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => updateMistakeData(
                                              editMistakeModel,
                                              studentDetailModel,
                                              account!),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
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
                                              'Chỉnh sửa',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
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
