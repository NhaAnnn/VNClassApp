import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';

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
  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Nguyeen van a xxxxxxxxxx',
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
                'DDuaf gion hu hai tai san cua nha truong xxxxxxx',
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
                    child: ButtonWidget(title: 'Lưu'),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Expanded(
                    child: ButtonWidget(
                      title: 'Thoát',
                      color: Colors.red,
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
}
