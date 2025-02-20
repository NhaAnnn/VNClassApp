import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text('Tên Vi Phạm:',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(editMistakeModel.m_name,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text('Môn Học',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                Expanded(
                  child: DropMenuWidget<String>(
                    hintText: 'Môn học',
                    items: ['Lớp 10', 'Lớp 11', 'Lớp 12'],
                    selectedItem: selectedItem,
                    onChanged: (newValue) {
                      setState(() {
                        selectedItem = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text('Thời Gian Vi Phạm:',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            TextField(
              controller: _dateController,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'Date',
                fillColor: Colors.white,
                suffixIcon: Icon(FontAwesomeIcons.calendar),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              readOnly: true,
              onTap: () {
                _selectDate();
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      title: 'Chỉnh sửa',
                      ontap: () {
                        updateMistakeData(
                            editMistakeModel, studentDetailModel, account!);
                      },
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height * 0.04),
                  Expanded(
                    child: ButtonWidget(
                      title: 'Thoát',
                      color: Colors.red,
                      ontap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
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
        print('$oldMonth + $monthString');

        final conductDocRef = FirebaseFirestore.instance
            .collection('CONDUCT_MONTH')
            .doc(idStudent);
        final conductSnapshot = await conductDocRef.get();

        if (conductSnapshot.exists) {
          final conductData = conductSnapshot.data() as Map<String, dynamic>;
          final monthData = conductData['_month'] as Map<String, dynamic>;

          // Cập nhật oldMonth
          if (monthData.containsKey('month$oldMonth') &&
              monthData['month$oldMonth'] is List &&
              monthData['month$oldMonth'].length >= 1) {
            int currentOldPoints =
                int.parse(monthData['month$oldMonth'][0].toString());

            print(
                'thang cu$oldMonth + diem tháng củ trước cập nhật $currentOldPoints');
            int updatedOldPoints =
                currentOldPoints + editMistakeModel.mistake!.minusPoint;
            print(
                'thang cu$oldMonth + diem tháng củ sau cập nhật $updatedOldPoints');

            // Cập nhật phần tử đầu tiên của oldMonth
            monthData['month$oldMonth'][0] = updatedOldPoints.toString();
          }

          if (monthData.containsKey('month$monthString') &&
              monthData['month$monthString'] is List &&
              monthData['month$monthString'].length >= 1) {
            int currentNewPoints =
                int.parse(monthData['month$monthString'][0].toString());
            print(
                'thang moi $monthString + diem tháng moi trước cập nhật $currentNewPoints');

            int updatedNewPoints =
                currentNewPoints - editMistakeModel.mistake!.minusPoint;
            print(
                'thang moi $monthString + diem tháng moi sau cập nhật $updatedNewPoints');

            // Cập nhật phần tử đầu tiên của monthString
            monthData['month$monthString'][0] = updatedNewPoints.toString();
          } else {
            print('Không tìm thấy tháng mới: month$monthString');
          }

          // Cập nhật lại toàn bộ map
          print('Dữ liệu tháng: $monthData');
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật thành công!')),
          );
          Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thành công!')),
        );
        Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}
