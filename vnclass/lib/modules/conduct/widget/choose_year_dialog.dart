import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/modules/conduct/view/all_conduct.dart';

class ChooseYearDialog extends StatefulWidget {
  const ChooseYearDialog({
    super.key,
  });

  @override
  State<ChooseYearDialog> createState() => _ChooseYearDialogState();
}

class _ChooseYearDialogState extends State<ChooseYearDialog> {
  List<String> listYear = [];
  bool isLoading = true; // Biến để kiểm tra trạng thái tải

  Future<void> fetchAllYears() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('YEAR').get();

      List<String> years = [];
      for (var doc in querySnapshot.docs) {
        years.add(doc.get('_year'));
      }
      setState(() {
        listYear = years; // Cập nhật danh sách năm học
        isLoading = false; // Đánh dấu là đã tải xong
      });
    } catch (e) {
      print("Error fetching years: $e");
      setState(() {
        isLoading = false; // Đánh dấu là đã tải xong dù có lỗi
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllYears();
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 1;

    return AlertDialog(
      title: Text('Chọn Năm Học'),
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue * 0.02),
          child: isLoading // Kiểm tra trạng thái tải
              ? Center(
                  child: CircularProgressIndicator()) // Hiển thị vòng xoay tải
              : Column(
                  children: List.generate(listYear.length, (index) {
                    final year = listYear[index];

                    return Card(
                      elevation: 8,
                      margin:
                          EdgeInsets.symmetric(vertical: paddingValue * 0.01),
                      color: Colors.blueAccent,
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AllConduct.routeName,
                            arguments: {'year': year},
                          );
                        },
                        title: Text(
                          year,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
        ),
      ),
    );
  }
}
