import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/mistake/models/student_mistake_model.dart';
import 'package:vnclass/modules/mistake/widget/item_class_mistake_student.dart';

class MistakeClassDetailPage extends StatefulWidget {
  const MistakeClassDetailPage({super.key});
  static const String routeName = '/mistake_class_detail_page';
  @override
  State<MistakeClassDetailPage> createState() => _MistakeClassDetailPageState();
}

class _MistakeClassDetailPageState extends State<MistakeClassDetailPage> {
  late Future<List<StudentMistakeModel>> futureMistakeClass;

  @override
  void initState() {
    super.initState();
    futureMistakeClass =
        fetchMistakeClasses(); // Gọi hàm lấy dữ liệu từ Firestore
  }

  Future<List<StudentMistakeModel>> fetchMistakeClasses() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .map((doc) => StudentMistakeModel.fromFirestore(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    String? selectedItem;

    return AppBarWidget(
      titleString: 'Cập nhất vi phạm lớp xxx',
      implementLeading: true,
      child: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
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
              ],
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black.withAlpha(50), // Border color
                width: 2, // Border width
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Mã HS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'Họ và Tên',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Số lần vi phạm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Xem',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Cập nhật',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentMistakeModel>>(
              future: futureMistakeClass,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Hiển thị loading
                }
                if (snapshot.hasError) {
                  return Text('Có lỗi xảy ra: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Không có dữ liệu');
                }

                // Hiển thị danh sách các lỗi
                return ListView(
                  children: snapshot.data!
                      .map((e) =>
                          ItemClassMistakeStudent(studentMistakeModel: e))
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
