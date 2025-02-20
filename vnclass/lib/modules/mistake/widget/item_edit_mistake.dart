import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_edit_mistake_page.dart';

class ItemEditMistake extends StatelessWidget {
  const ItemEditMistake({
    super.key,
    this.studentDetailModel,
    required this.onItemDeleted,
    this.month,
  });

  final StudentDetailModel? studentDetailModel;
  final VoidCallback onItemDeleted;
  final String? month;

  Future<List<EditMistakeModel>> _fetchItems() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MISTAKE_MONTH')
        .where('_month', isEqualTo: month)
        .get();

    List<EditMistakeModel> items = [];
    for (var doc in snapshot.docs) {
      EditMistakeModel item = await EditMistakeModel.fromFirestore(doc);
      items.add(item);
    }
    return items;
  }

  Future<void> _deleteItem(EditMistakeModel item) async {
    String classId = studentDetailModel?.classID ?? '';
    String stdId = item.std_id;
    String mmId = item.mm_id;
    String time = item.mm_time; // Giả sử định dạng là yyyy-mm-dd
    int month = int.parse(time.split('-')[1]); // Lấy tháng từ thời gian
    int minusPoints = item.mistake?.minusPoint ?? 0;

    // Lấy dữ liệu từ collection CLASS
    DocumentReference classDocRef =
        FirebaseFirestore.instance.collection('CLASS').doc(classId);
    DocumentSnapshot classDocSnapshot = await classDocRef.get();
    Map<String, dynamic> data = classDocSnapshot.data() as Map<String, dynamic>;

    // Cập nhật số lượng
    int numberOfMisALL = int.parse(data['_numberOfMisAll'].toString()) - 1;

    // Cập nhật dữ liệu
    await classDocRef.update({
      '_numberOfMisAll': numberOfMisALL.toString(),
      '_numberOfMisS2': (month >= 1 && month <= 5)
          ? (int.parse(data['_numberOfMisS2'].toString()) - 1).toString()
          : data['_numberOfMisS2'].toString(),
      '_numberOfMisS1': (month >= 9 && month <= 12)
          ? (int.parse(data['_numberOfMisS1'].toString()) - 1).toString()
          : data['_numberOfMisS1'].toString(),
    });

    // Cập nhật collection CONDUCT_MONTH
    DocumentReference conductMonthDocRef =
        FirebaseFirestore.instance.collection('CONDUCT_MONTH').doc(stdId);
    DocumentSnapshot conductSnapshot = await conductMonthDocRef.get();

    if (conductSnapshot.exists) {
      final conductData = conductSnapshot.data() as Map<String, dynamic>;
      final monthData = conductData['_month'] as Map<String, dynamic>;

      // Tạo khóa tháng
      String monthString = time.split('-')[1]; // Lấy tháng từ thời gian
      String monthKey =
          'month${monthString.replaceFirst('0', '')}'; // Khóa tháng

      // Cập nhật phần tử đầu tiên trong tháng hiện tại
      if (monthData.containsKey(monthKey) &&
          monthData[monthKey] is List &&
          monthData[monthKey].length >= 2) {
        int currentPoints = int.parse(monthData[monthKey][0].toString());
        int updatedPoints =
            currentPoints + minusPoints; // Giảm theo điểm đã trừ

        // Cập nhật phần tử đầu tiên
        monthData[monthKey][0] = updatedPoints;

        // Cập nhật lại toàn bộ map
        await conductMonthDocRef.update({'_month': monthData});
      }
    }
    // print('id mm$mmId');
    // Xóa tài liệu trong collection MISTAKE_MONTH
    DocumentReference mistakeMonthDocRef =
        FirebaseFirestore.instance.collection('MISTAKE_MONTH').doc(mmId);
    await mistakeMonthDocRef.delete();

    onItemDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EditMistakeModel>>(
      future: _fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data!;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    item.m_name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                children: [
                  ListTile(
                    title: Text('Writer: ${item.acc_name}'),
                  ),
                  ListTile(
                    title: Text('Time: ${item.mm_time}'),
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(MistakeEditMistakePage.routeName,
                                      arguments: PackageData(
                                        agrReq: item,
                                        agr2: studentDetailModel,
                                      )),
                              child: ButtonWidget(title: 'Chỉnh sửa'),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.04,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await _deleteItem(item);
                                // Thực hiện một hành động sau khi xóa (nếu cần)
                              },
                              child: ButtonWidget(
                                title: 'Xóa',
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
