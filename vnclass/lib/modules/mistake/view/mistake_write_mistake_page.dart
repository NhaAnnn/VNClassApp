import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
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
  String? receivedArgumentMistake;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Đặt giá trị mặc định cho _dateController là ngày hiện tại
    _dateController.text = DateTime.now().toLocal().toString().split(" ")[0];
  }

  @override
  Widget build(BuildContext context) {
    //nhan du lieu tu itemwritemistake //arg2 mistake arg3 studentmodel arg4 acc
    final args = ModalRoute.of(context)!.settings.arguments as PackageData;
    StudentDetailModel studentDetailModel = args.agr3;
    MistakeModel mistakeModel = args.agr2;
    AccountModel accountModel = args.agr4;

    return AppBarWidget(
      titleString: studentDetailModel.nameStudent,
      implementLeading: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              'Tên Vi Phạm:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
              ),
              child: Text(
                mistakeModel.nameMistake,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              'Môn Học',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Thời Gian Vi Phạm:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TextField(
              controller: _dateController,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Date',
                fillColor: Colors.white,
                suffixIcon: Icon(FontAwesomeIcons.calendar),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              readOnly: true,
              onTap: () {
                _selectDate();
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      title: 'Lưu',
                      ontap: () async {
                        saveMistakeData(studentDetailModel.classID,
                            mistakeModel, studentDetailModel, accountModel);
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.height * 0.04,
                  ),
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
            )
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
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> saveMistakeData(
    String idClass,
    MistakeModel mistakeModel,
    StudentDetailModel studentDetailModel,
    AccountModel accountModel,
  ) async {
    try {
      // Truy cập Firestore
      final classDocRef =
          FirebaseFirestore.instance.collection('CLASS').doc(idClass);
      final classSnapshot = await classDocRef.get();

      if (classSnapshot.exists) {
        // Lấy dữ liệu hiện tại
        final data = classSnapshot.data()!;
        int numberOfMisALL = int.parse(data['_numberOfMisAll'].toString()) + 1;

        // Cập nhật dữ liệu
        await classDocRef.update({
          '_numberOfMisAll': numberOfMisALL.toString(), // Chuyển đổi sang chuỗi
          '_numberOfMisS2':
              (DateTime.now().month >= 1 && DateTime.now().month <= 5)
                  ? (int.parse(data['_numberOfMisS2'].toString()) + 1)
                      .toString() // Chuyển đổi sang chuỗi
                  : data['_numberOfMisS2'].toString(), // Chuyển đổi sang chuỗi
          '_numberOfMisS1':
              (DateTime.now().month >= 9 && DateTime.now().month <= 12)
                  ? (int.parse(data['_numberOfMisS1'].toString()) + 1)
                      .toString() // Chuyển đổi sang chuỗi
                  : data['_numberOfMisS1'].toString(), // Chuyển đổi sang chuỗi
        });

        final time = DateTime.now();
        final formattedTime =
            '${time.second}${time.minute}${time.day}${time.month}${time.year}';
        String idStudent = studentDetailModel.id;
        final idDoc = '$idStudent+$formattedTime';

        // Lấy giá trị tháng từ _dateController
        String monthString =
            _dateController.text.split('-')[1]; // Cắt để lấy tháng
        String monthKey =
            'month${monthString.replaceFirst('0', '')}'; // Khóa tháng
        String monthSave = 'Tháng ${monthString.replaceFirst('0', '')}';
        // Tìm document trong CONDUCT_MONTH
        final conductDocRef = FirebaseFirestore.instance
            .collection('CONDUCT_MONTH')
            .doc(idStudent);
        final conductSnapshot = await conductDocRef.get();

        if (conductSnapshot.exists) {
          final conductData = conductSnapshot.data() as Map<String, dynamic>;
          final monthData = conductData['_month'] as Map<String, dynamic>;

          // Cập nhật phần tử đầu tiên trong tháng hiện tại
          if (monthData.containsKey(monthKey) &&
              monthData[monthKey] is List &&
              monthData[monthKey].length >= 2) {
            int currentPoints = int.parse(monthData[monthKey][0].toString());
            int updatedPoints = currentPoints -
                mistakeModel.minusPoint; // Giả sử mistakeModel có trường point

            // Cập nhật phần tử đầu tiên
            monthData[monthKey][0] = updatedPoints;

            // Cập nhật lại toàn bộ map
            await conductDocRef.update({'_month': monthData});

            // Tạo document mới trong MISTAKE_MONTH
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
              '_subject': selectedItem ?? '', // Môn học
              '_time': _dateController.text,
            });

            // Thông báo thành công
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lưu thành công!')),
            );
            Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
              Navigator.pop(context);
            });
          } else {
            // Xử lý trường hợp không tìm thấy tháng
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không tìm thấy dữ liệu tháng!')),
            );
          }
        } else {
          // Nếu không tìm thấy document CONDUCT_MONTH
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy dữ liệu conduct!')),
          );
        }
      } else {
        // Nếu không tìm thấy document CLASS
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy lớp!')),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}
