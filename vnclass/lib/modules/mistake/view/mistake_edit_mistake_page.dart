import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_snack_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';

class MistakeEditMistakePage extends StatefulWidget {
  const MistakeEditMistakePage({super.key});
  static const String routeName = '/mistake_edit_mistake_page';

  @override
  State<MistakeEditMistakePage> createState() => _MistakeEditMistakePageState();
}

class _MistakeEditMistakePageState extends State<MistakeEditMistakePage> {
  String? selectedItem;
  String? oldMonth;
  bool isLoading = false;
  final TextEditingController _dateController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PackageData;
    EditMistakeModel editMistakeModel = args.agrReq;
    StudentDetailModel studentDetailModel = args.agr2;
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    return AppBarWidget(
      titleString: studentDetailModel.nameStudent,
      implementLeading: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
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
                border: Border.all(color: Colors.redAccent.shade100),
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
            Text(
              'Môn học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            DropMenuWidget<String>(
              hintText: 'Chọn môn học',
              items: [
                'Ngữ văn',
                'Toán',
                'Ngoại ngữ',
                'Giáo dục công dân',
                'Lịch sử',
                'Địa lý',
                'Sinh học',
                'Hóa học',
                'Vật lý',
                'Thể dục',
                'Tin học',
                'Nghệ thuật',
                'Khoa học tự nhiên',
                'Khoa học xã hội',
                'Giáo dục QP&AN',
                'Khác...'
              ],
              selectedItem: selectedItem,
              onChanged: (newValue) {
                setState(() {
                  selectedItem = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
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
              style: const TextStyle(fontSize: 16, color: Colors.black87),
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
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Chỉnh sửa',
                    color: Colors.blue.shade700,
                    ontap: isLoading
                        ? null
                        : () async {
                            updateMistakeData(
                                editMistakeModel, studentDetailModel, account!);
                            String accid =
                                await StudentController.fetchAccountByID(
                                    studentDetailModel.idStudent);
                            List<String> deviceTokens =
                                await AccountController.fetchTokens(accid);
                            await NotificationService.sendNotification(
                                accid, //tim id accacc
                                deviceTokens,
                                'Thông báo vi phạm',
                                'Một vi phạm của bạn đã được chỉnh sửa: Vi phạm ${editMistakeModel.m_name} vào ${editMistakeModel.mm_time}');

                            await NotificationController.createNotification(
                                accid,
                                'Thông báo vi phạm',
                                'Một vi phạm của bạn đã được chỉnh sửa: Vi phạm ${editMistakeModel.m_name} vào ${editMistakeModel.mm_time}');
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonWidget(
                    title: 'Thoát',
                    color: Colors.red.shade600,
                    ontap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      isLoading = true; // Hiển thị tiến trình khi bắt đầu
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

      // Lấy thông tin từ SET_UP để xác định conductType
      final setPointRef =
          FirebaseFirestore.instance.collection('SET_UP').doc('setPoint');
      final setPointSnapshot = await setPointRef.get();
      if (!setPointSnapshot.exists) {
        throw Exception('Không tìm thấy dữ liệu setPoint');
      }
      final pointsData = setPointSnapshot.data()!['points'];

      // Nếu tháng thay đổi
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
          print(
              'Cập nhật tháng cũ - Month: $oldMonthKey, Points: $updatedOldPoints, Conduct: $oldConductType');
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
          print(
              'Cập nhật tháng mới - Month: $monthKey, Points: $updatedNewPoints, Conduct: $newConductType');
        }
      } else {
        // Nếu tháng không thay đổi, chỉ cập nhật điểm và conductType cho tháng hiện tại
        if (monthData.containsKey(monthKey) &&
            monthData[monthKey] is List &&
            monthData[monthKey].length >= 2) {
          int currentPoints = int.parse(monthData[monthKey][0].toString());
          int updatedPoints = currentPoints +
              (editMistakeModel.mistake?.minusPoint ??
                  0) - // Điểm cũ được hoàn lại
              (editMistakeModel.mistake?.minusPoint ?? 0); // Điểm mới bị trừ
          String conductType = _determineConductType(updatedPoints, pointsData);
          monthData[monthKey] = [updatedPoints.toString(), conductType];
          print(
              'Cập nhật cùng tháng - Month: $monthKey, Points: $updatedPoints, Conduct: $conductType');
        }
      }

      // Cập nhật CONDUCT_MONTH
      await conductDocRef.update({'_month': monthData});
      print('Đã cập nhật CONDUCT_MONTH với monthData: $monthData');

      // Cập nhật MISTAKE_MONTH
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
      print('Đã cập nhật MISTAKE_MONTH với ID: ${editMistakeModel.mm_id}');

      // Tính lại conductTerm1, conductTerm2, conductAllYear
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
      print("Dữ liệu term1: $term1Count");

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
      print("Dữ liệu term2: $term2Count");

      final setTerm1Ref =
          FirebaseFirestore.instance.collection('SET_UP').doc('setTerm1');
      final setTerm2Ref =
          FirebaseFirestore.instance.collection('SET_UP').doc('setTerm2');
      final setTerm3Ref =
          FirebaseFirestore.instance.collection('SET_UP').doc('setTerm3');

      final setTerm1Snap = await setTerm1Ref.get();
      final setTerm2Snap = await setTerm2Ref.get();
      final setTerm3Snap = await setTerm3Ref.get();

      String conductTerm1 = '';
      String conductTerm2 = '';

      if (setTerm1Snap.exists) {
        final conditions = setTerm1Snap.data()!['conditions'];
        print('Conditions Term1: $conditions');
        conductTerm1 = _determineConduct(conditions, term1Count['Tốt']!,
            term1Count['Khá']!, term1Count['Đạt']!, term1Count['Chưa Đạt']!);
      }
      print('Conduct Term1: $conductTerm1');

      if (setTerm2Snap.exists) {
        final conditions = setTerm2Snap.data()!['conditions'];
        print('Conditions Term2: $conditions');
        conductTerm2 = _determineConduct(conditions, term2Count['Tốt']!,
            term2Count['Khá']!, term2Count['Đạt']!, term2Count['Chưa Đạt']!);
      }
      print('Conduct Term2: $conductTerm2');

      String conductAllYear = '';
      if (setTerm3Snap.exists) {
        final conditions = setTerm3Snap.data()!['conditions'];
        print('Conditions Term3: $conditions');
        for (var type in ['good', 'fair', 'pass', 'fail']) {
          for (var condition in conditions[type]) {
            if (condition['hki'] == conductTerm1 &&
                condition['hkii'] == conductTerm2) {
              conductAllYear = type == 'good'
                  ? 'Tốt'
                  : type == 'fair'
                      ? 'Khá'
                      : type == 'pass'
                          ? 'Đạt'
                          : 'Chưa Đạt';
              break;
            }
          }
          if (conductAllYear.isNotEmpty) break;
        }
      }
      print('Conduct All Year: $conductAllYear');

      // Cập nhật STUDENT_DETAIL
      await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .doc(idStudent)
          .update({
        '_conductAllYear': conductAllYear,
        '_conductTerm1': conductTerm1,
        '_conductTerm2': conductTerm2,
      });
      print('Đã cập nhật STUDENT_DETAIL');

      // Thoát trang và trả về kết quả thành công
      if (mounted) {
        Navigator.pop(context, true); // Trả về true để báo thành công
      }
    } catch (e) {
      print('Lỗi xảy ra: $e');
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
          isLoading = false; // Tắt tiến trình khi hoàn tất
        });
      }
    }
  }

  // Hàm xác định conductType dựa trên điểm
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

  // Hàm xác định conduct dựa trên điều kiện
  String _determineConduct(
      Map<String, dynamic> conditions, int good, int fair, int pass, int fail) {
    print(
        'Determine Conduct - Input: good=$good, fair=$fair, pass=$pass, fail=$fail');
    for (var type in ['good', 'fair', 'pass', 'fail']) {
      for (var condition in conditions[type]) {
        if (int.parse(condition['good']) == good &&
            int.parse(condition['fair']) == fair &&
            int.parse(condition['pass']) == pass &&
            int.parse(condition['fail']) == fail) {
          String result = type == 'good'
              ? 'Tốt'
              : type == 'fair'
                  ? 'Khá'
                  : type == 'pass'
                      ? 'Đạt'
                      : 'Chưa Đạt';
          print('Determine Conduct - Result: $result');
          return result;
        }
      }
    }
    print('Determine Conduct - Default: Chưa Đạt');
    return 'Chưa Đạt';
  }
}
