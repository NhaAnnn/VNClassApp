import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_snack_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';

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
              items: ['Lớp 10', 'Lớp 11', 'Lớp 12'],
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
                        : () => _saveMistakeData(
                            studentDetailModel, mistakeModel, accountModel),
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
      final classDocRef = FirebaseFirestore.instance
          .collection('CLASS')
          .doc(studentDetailModel.classID);
      final classSnapshot = await classDocRef.get();

      if (classSnapshot.exists) {
        final data = classSnapshot.data()!;
        int numberOfMisALL = int.parse(data['_numberOfMisAll'].toString()) + 1;

        await classDocRef.update({
          '_numberOfMisAll': numberOfMisALL.toString(),
          '_numberOfMisS2': (DateTime.now().month >= 1 &&
                  DateTime.now().month <= 5)
              ? (int.parse(data['_numberOfMisS2'].toString()) + 1).toString()
              : data['_numberOfMisS2'].toString(),
          '_numberOfMisS1': (DateTime.now().month >= 9 &&
                  DateTime.now().month <= 12)
              ? (int.parse(data['_numberOfMisS1'].toString()) + 1).toString()
              : data['_numberOfMisS1'].toString(),
        });

        final time = DateTime.now();
        final formattedTime =
            '${time.second}${time.minute}${time.day}${time.month}${time.year}';
        String idStudent = studentDetailModel.id;
        final idDoc = '$idStudent+$formattedTime';

        String monthString = _dateController.text.split('-')[1];
        String monthKey = 'month${monthString.replaceFirst('0', '')}';
        String monthSave = 'Tháng ${monthString.replaceFirst('0', '')}';

        final conductDocRef = FirebaseFirestore.instance
            .collection('CONDUCT_MONTH')
            .doc(idStudent);
        final conductSnapshot = await conductDocRef.get();

        if (conductSnapshot.exists) {
          final conductData = conductSnapshot.data() as Map<String, dynamic>;
          final monthData = conductData['_month'] as Map<String, dynamic>;

          if (monthData.containsKey(monthKey) &&
              monthData[monthKey] is List &&
              monthData[monthKey].length >= 2) {
            int currentPoints = int.parse(monthData[monthKey][0].toString());
            String updatedPoints =
                (currentPoints - mistakeModel.minusPoint).toString();

            monthData[monthKey][0] = updatedPoints;
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

            showCustomSnackBar(context, message: 'Lưu thành công!');
            Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
              Navigator.pop(context);
            });
          } else {
            showCustomSnackBar(context,
                message: 'Không tìm thấy dữ liệu tháng!', isError: true);
          }
        } else {
          showCustomSnackBar(context,
              message: 'Không tìm thấy dữ liệu conduct!', isError: true);
        }
      } else {
        showCustomSnackBar(context,
            message: 'Không tìm thấy lớp!', isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context,
          message: 'Lỗi: $e',
          isError: true,
          duration: const Duration(seconds: 3));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
