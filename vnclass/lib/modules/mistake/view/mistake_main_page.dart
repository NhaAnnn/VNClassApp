import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/widget/item_class_mistake.dart';

class MistakeMainPage extends StatefulWidget {
  const MistakeMainPage({super.key});
  static const String routeName = '/mistake_main_page';
  @override
  State<MistakeMainPage> createState() => _MistakeMainPageState();
}

class _MistakeMainPageState extends State<MistakeMainPage> {
  late Future<List<ClassMistakeModel>> futureMistakeClass;

  @override
  void initState() {
    super.initState();
    futureMistakeClass =
        fetchMistakeClasses(); // Gọi hàm lấy dữ liệu từ Firestore
  }

  Future<List<ClassMistakeModel>> fetchMistakeClasses() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .map((doc) => ClassMistakeModel.fromFirestore(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    String? selectedItem;

    return AppBarWidget(
      titleString: 'Cập Nhật Vi Phạm',
      implementLeading: true,
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Lớp',
                  items: ['Lớp 10', 'Lớp 11', 'Lớp 12'],
                  selectedItem: selectedItem,
                  onChanged: (newValue) {
                    setState(() {
                      selectedItem = newValue;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Học kỳ',
                  items: ['Item 1', 'Item 2', 'Item 3'],
                  selectedItem: selectedItem,
                  onChanged: (newValue) {
                    setState(() {
                      selectedItem = newValue;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropMenuWidget<String>(
                  hintText: 'Năm học',
                  items: ['Item 1', 'Item 2', 'Item 3'],
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
          SizedBox(height: 20),
          TextField(
            style: TextStyle(fontSize: 18),
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
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            // Sử dụng Expanded để cho ListView chiếm không gian còn lại
            child: FutureBuilder<List<ClassMistakeModel>>(
              future: futureMistakeClass,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có dữ liệu'));
                }

                // Hiển thị danh sách các lỗi
                return ListView(
                  children: snapshot.data!
                      .map((e) => ItemClassModels(classMistakeModel: e))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
