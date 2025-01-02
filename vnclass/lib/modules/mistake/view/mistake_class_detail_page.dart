import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';

class MistakeClassDetailPage extends StatefulWidget {
  const MistakeClassDetailPage({super.key});
  static const String routeName = '/mistake_class_detail_page';
  @override
  State<MistakeClassDetailPage> createState() => _MistakeClassDetailPageState();
}

class _MistakeClassDetailPageState extends State<MistakeClassDetailPage> {
  @override
  Widget build(BuildContext context) {
    String? selectedItem;

    return AppBarWidget(
      titleString: 'Cập nhất vi phạm lớp xxx',
      implementLeading: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Tháng',
                  items: ['Lớp 10', 'Lớp 11', 'Lớp 12'],
                  selectedItem: selectedItem,
                  onChanged: (newValue) {
                    setState(() {
                      selectedItem = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              style: TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Icon(
                    Icons.search_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,

                // Thêm viền bên ngoài
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Màu viền
                    width: 2.0, // Độ dày viền
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueAccent, // Màu viền khi focus
                    width: 2.0, // Độ dày viền
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
