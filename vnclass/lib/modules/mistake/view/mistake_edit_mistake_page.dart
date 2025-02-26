import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_snack_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';

class MistakeEditMistakePage extends StatefulWidget {
  const MistakeEditMistakePage({super.key});
  static const String routeName = '/mistake_edit_mistake_page';

  @override
  State<MistakeEditMistakePage> createState() => _MistakeEditMistakePageState();
}

class _MistakeEditMistakePageState extends State<MistakeEditMistakePage> {
  String? selectedItem;
  String? oldMonth;
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
              items: ['Lớp 10', 'Lớp 11', 'Lớp 12'],
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
                    ontap: () {
                      updateMistakeData(
                          editMistakeModel, studentDetailModel, account!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonWidget(
                    title: 'Thoát',
                    color: Colors.red.shade600,
                    ontap: () {
                      Navigator.pop(context);
                    },
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
    try {
      String idStudent = studentDetailModel.id;
      String monthString =
          _dateController.text.split('-')[1].replaceFirst('0', '');

      if (oldMonth != monthString) {
        final conductDocRef = FirebaseFirestore.instance
            .collection('CONDUCT_MONTH')
            .doc(idStudent);
        final conductSnapshot = await conductDocRef.get();

        if (conductSnapshot.exists) {
          final conductData = conductSnapshot.data() as Map<String, dynamic>;
          final monthData = conductData['_month'] as Map<String, dynamic>;

          if (monthData.containsKey('month$oldMonth') &&
              monthData['month$oldMonth'] is List &&
              monthData['month$oldMonth'].length >= 1) {
            int currentOldPoints =
                int.parse(monthData['month$oldMonth'][0].toString());
            int updatedOldPoints =
                currentOldPoints + editMistakeModel.mistake!.minusPoint;
            monthData['month$oldMonth'][0] = updatedOldPoints.toString();
          }

          if (monthData.containsKey('month$monthString') &&
              monthData['month$monthString'] is List &&
              monthData['month$monthString'].length >= 1) {
            int currentNewPoints =
                int.parse(monthData['month$monthString'][0].toString());
            int updatedNewPoints =
                currentNewPoints - editMistakeModel.mistake!.minusPoint;
            monthData['month$monthString'][0] = updatedNewPoints.toString();
          }

          await conductDocRef.update({'_month': monthData});
          await FirebaseFirestore.instance
              .collection('MISTAKE_MONTH')
              .doc(editMistakeModel.mm_id)
              .update({
            'ACC_id': accountModel.idAcc,
            'ACC_name': accountModel.accName,
            '_month': 'Tháng $monthString',
            '_subject': selectedItem ?? '',
            '_time': _dateController.text,
          });

          showCustomSnackBar(context, message: 'Cập nhật thành công!');
          Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
            Navigator.pop(context);
          });
        }
      } else {
        await FirebaseFirestore.instance
            .collection('MISTAKE_MONTH')
            .doc(editMistakeModel.mm_id)
            .update({
          'ACC_id': accountModel.idAcc,
          'ACC_name': accountModel.accName,
          '_month': 'Tháng $monthString',
          '_subject': selectedItem ?? '',
          '_time': _dateController.text,
        });

        showCustomSnackBar(context, message: 'Cập nhật thành công!');
        Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      showCustomSnackBar(
        context,
        message: 'Lỗi: $e',
        isError: true,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
