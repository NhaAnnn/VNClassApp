import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_snack_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';

class MistakeWriteMistakePage extends StatefulWidget {
  const MistakeWriteMistakePage({super.key});
  static const String routeName = '/mistake_write_mistake_page';

  @override
  State<MistakeWriteMistakePage> createState() =>
      _MistakeWriteMistakePageState();
}

class _MistakeWriteMistakePageState extends State<MistakeWriteMistakePage> {
  String? selectedItem;
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toLocal().toString().split(" ")[0];
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PackageData;
    StudentDetailModel studentDetailModel = args.agr3;
    MistakeModel mistakeModel = args.agr2;
    AccountModel accountModel = args.agr4;

    return AppBarWidget(
      titleString: studentDetailModel.nameStudent,
      implementLeading: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
              style: const TextStyle(fontSize: 16, color: Colors.black87),
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
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1976D2), width: 2),
                ),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFF43A047),
                    ontap: isLoading
                        ? null
                        : () async {
                            _saveMistakeData(
                                studentDetailModel, mistakeModel, accountModel);
                            String accid =
                                await StudentController.fetchAccountByID(
                                    studentDetailModel.idStudent);
                            List<String> deviceTokens =
                                await AccountController.fetchTokens(accid);
                            await NotificationService.sendNotification(
                                accid, //tim id accacc
                                deviceTokens,
                                'Thông báo vi phạm',
                                'Bạn có 1 vi phạm mới: ${mistakeModel.nameMistake}');
                            await NotificationController.createNotification(
                                accid,
                                'Thông báo vi phạm',
                                'Bạn có 1 vi phạm mới: ${mistakeModel.nameMistake}');
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
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonWidget(
                    title: 'Thoát',
                    color: const Color(0xFFE53935),
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
      print('Bắt đầu xử lý - ID Student: ${studentDetailModel.id}');

      final classDocRef = FirebaseFirestore.instance
          .collection('CLASS')
          .doc(studentDetailModel.classID);
      final classSnapshot = await classDocRef.get();

      if (classSnapshot.exists) {
        final data = classSnapshot.data()!;
        print('Dữ liệu CLASS: $data');
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
        print('Đã cập nhật CLASS - numberOfMisALL: $numberOfMisALL');

        final time = DateTime.now();
        final formattedTime =
            '${time.second}${time.minute}${time.day}${time.month}${time.year}';
        String idStudent = studentDetailModel.id;
        final idDoc = '$idStudent+$formattedTime';
        print('ID Document: $idDoc');

        String monthString = _dateController.text.split('-')[1];
        String monthKey = 'month${monthString.replaceFirst('0', '')}';
        String monthSave = 'Tháng ${monthString.replaceFirst('0', '')}';
        print('Month Key: $monthKey, Month Save: $monthSave');

        final conductDocRef = FirebaseFirestore.instance
            .collection('CONDUCT_MONTH')
            .doc(idStudent);
        final conductSnapshot = await conductDocRef.get();

        if (conductSnapshot.exists) {
          final conductData = conductSnapshot.data() as Map<String, dynamic>;
          print('Dữ liệu CONDUCT_MONTH ban đầu: $conductData');
          final monthData = conductData['_month'] as Map<String, dynamic>;

          if (monthData.containsKey(monthKey) &&
              monthData[monthKey] is List &&
              monthData[monthKey].length >= 2) {
            int currentPoints = int.parse(monthData[monthKey][0]);
            String updatedPoints =
                (currentPoints - mistakeModel.minusPoint).toString();
            print(
                'Current Points: $currentPoints, Updated Points: $updatedPoints');

            final setPointRef =
                FirebaseFirestore.instance.collection('SET_UP').doc('setPoint');
            final setPointSnapshot = await setPointRef.get();
            String conductType = '';

            if (setPointSnapshot.exists) {
              final pointsData = setPointSnapshot.data()!['points'];
              print('Points Data from setPoint: $pointsData');
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
              print('Conduct Type: $conductType');
            }

            monthData[monthKey][0] = updatedPoints.toString();
            monthData[monthKey][1] = conductType;
            await conductDocRef.update({'_month': monthData});
            print('Đã cập nhật CONDUCT_MONTH với monthData: $monthData');

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
            print('Đã lưu MISTAKE_MONTH với ID: $idDoc');

            final updatedConductSnapshot = await conductDocRef.get();
            if (!updatedConductSnapshot.exists) {
              throw Exception('Không thể lấy dữ liệu CONDUCT_MONTH mới');
            }
            final allConductData = updatedConductSnapshot.data()!['_month']
                as Map<String, dynamic>;
            print('Dữ liệu CONDUCT_MONTH mới sau cập nhật: $allConductData');

            print("ID studentdetail: $idStudent");
            final studentDocRef = FirebaseFirestore.instance
                .collection('STUDENT_DETAIL')
                .doc(idStudent);

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
              conductTerm1 = _determineConduct(
                  conditions,
                  term1Count['Tốt']!,
                  term1Count['Khá']!,
                  term1Count['Đạt']!,
                  term1Count['Chưa Đạt']!);
            }
            print('Conduct Term1: $conductTerm1');

            if (setTerm2Snap.exists) {
              final conditions = setTerm2Snap.data()!['conditions'];
              print('Conditions Term2: $conditions');
              conductTerm2 = _determineConduct(
                  conditions,
                  term2Count['Tốt']!,
                  term2Count['Khá']!,
                  term2Count['Đạt']!,
                  term2Count['Chưa Đạt']!);
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

            await studentDocRef.update({
              '_conductAllYear': conductAllYear,
              '_conductTerm1': conductTerm1,
              '_conductTerm2': conductTerm2,
            });
            print('Đã cập nhật STUDENT_DETAIL');

            // Thoát trang và trả về kết quả thành công
            if (mounted) {
              Navigator.pop(context, true); // Trả về true để báo thành công
            }
          } else {
            print('Không tìm thấy monthKey hoặc dữ liệu không hợp lệ');
            if (mounted) {
              showCustomSnackBar(context,
                  message: 'Không tìm thấy dữ liệu tháng!', isError: true);
            }
          }
        } else {
          print('Không tìm thấy CONDUCT_MONTH');
          if (mounted) {
            showCustomSnackBar(context,
                message: 'Không tìm thấy dữ liệu conduct!', isError: true);
          }
        }
      } else {
        print('Không tìm thấy CLASS');
        if (mounted) {
          showCustomSnackBar(context,
              message: 'Không tìm thấy lớp!', isError: true);
        }
      }
    } catch (e) {
      print('Lỗi xảy ra: $e');
      if (mounted) {
        showCustomSnackBar(context,
            message: 'Lỗi: $e',
            isError: true,
            duration: const Duration(seconds: 3));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Kết thúc xử lý');
    }
  }

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
    return 'Chưa Đạt'; // Default case
  }

  // Future<void> _saveMistakeData(
  //   StudentDetailModel studentDetailModel,
  //   MistakeModel mistakeModel,
  //   AccountModel accountModel,
  // ) async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     final classDocRef = FirebaseFirestore.instance
  //         .collection('CLASS')
  //         .doc(studentDetailModel.classID);
  //     final classSnapshot = await classDocRef.get();

  //     if (classSnapshot.exists) {
  //       final data = classSnapshot.data()!;
  //       int numberOfMisALL = int.parse(data['_numberOfMisAll'].toString()) + 1;

  //       await classDocRef.update({
  //         '_numberOfMisAll': numberOfMisALL.toString(),
  //         '_numberOfMisS2': (DateTime.now().month >= 1 &&
  //                 DateTime.now().month <= 5)
  //             ? (int.parse(data['_numberOfMisS2'].toString()) + 1).toString()
  //             : data['_numberOfMisS2'].toString(),
  //         '_numberOfMisS1': (DateTime.now().month >= 9 &&
  //                 DateTime.now().month <= 12)
  //             ? (int.parse(data['_numberOfMisS1'].toString()) + 1).toString()
  //             : data['_numberOfMisS1'].toString(),
  //       });

  //       final time = DateTime.now();
  //       final formattedTime =
  //           '${time.second}${time.minute}${time.day}${time.month}${time.year}';
  //       String idStudent = studentDetailModel.id;
  //       final idDoc = '$idStudent+$formattedTime';

  //       String monthString = _dateController.text.split('-')[1];
  //       String monthKey = 'month${monthString.replaceFirst('0', '')}';
  //       String monthSave = 'Tháng ${monthString.replaceFirst('0', '')}';

  //       final conductDocRef = FirebaseFirestore.instance
  //           .collection('CONDUCT_MONTH')
  //           .doc(idStudent);
  //       final conductSnapshot = await conductDocRef.get();

  //       if (conductSnapshot.exists) {
  //         final conductData = conductSnapshot.data() as Map<String, dynamic>;
  //         final monthData = conductData['_month'] as Map<String, dynamic>;

  //         if (monthData.containsKey(monthKey) &&
  //             monthData[monthKey] is List &&
  //             monthData[monthKey].length >= 2) {
  //           int currentPoints = int.parse(monthData[monthKey][0].toString());
  //           String updatedPoints =
  //               (currentPoints - mistakeModel.minusPoint).toString();

  //           monthData[monthKey][0] = updatedPoints;
  //           await conductDocRef.update({'_month': monthData});

  //           await FirebaseFirestore.instance
  //               .collection('MISTAKE_MONTH')
  //               .doc(idDoc)
  //               .set({
  //             'ACC_id': accountModel.idAcc,
  //             'ACC_name': accountModel.accName,
  //             'M_id': mistakeModel.idMistake,
  //             'M_name': mistakeModel.nameMistake,
  //             'STD_id': idStudent,
  //             '_id': idDoc,
  //             '_month': monthSave,
  //             '_subject': selectedItem ?? '',
  //             '_time': _dateController.text,
  //           });

  //           showCustomSnackBar(context, message: 'Lưu thành công!');
  //           Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
  //             Navigator.pop(context);
  //           });
  //         } else {
  //           showCustomSnackBar(context,
  //               message: 'Không tìm thấy dữ liệu tháng!', isError: true);
  //         }
  //       } else {
  //         showCustomSnackBar(context,
  //             message: 'Không tìm thấy dữ liệu conduct!', isError: true);
  //       }
  //     } else {
  //       showCustomSnackBar(context,
  //           message: 'Không tìm thấy lớp!', isError: true);
  //     }
  //   } catch (e) {
  //     showCustomSnackBar(context,
  //         message: 'Lỗi: $e',
  //         isError: true,
  //         duration: const Duration(seconds: 3));
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
}
