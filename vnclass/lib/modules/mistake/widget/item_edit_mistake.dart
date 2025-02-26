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
        .where('STD_id', isEqualTo: studentDetailModel!.id)
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
    String time = item.mm_time;
    int month = int.parse(time.split('-')[1]);
    int minusPoints = item.mistake?.minusPoint ?? 0;

    // Cập nhật CLASS
    DocumentReference classDocRef =
        FirebaseFirestore.instance.collection('CLASS').doc(classId);
    DocumentSnapshot classDocSnapshot = await classDocRef.get();
    Map<String, dynamic> data = classDocSnapshot.data() as Map<String, dynamic>;

    int numberOfMisALL = int.parse(data['_numberOfMisAll'].toString()) - 1;
    await classDocRef.update({
      '_numberOfMisAll': numberOfMisALL.toString(),
      '_numberOfMisS2': (month >= 1 && month <= 5)
          ? (int.parse(data['_numberOfMisS2'].toString()) - 1).toString()
          : data['_numberOfMisS2'].toString(),
      '_numberOfMisS1': (month >= 9 && month <= 12)
          ? (int.parse(data['_numberOfMisS1'].toString()) - 1).toString()
          : data['_numberOfMisS1'].toString(),
    });

    // Cập nhật CONDUCT_MONTH
    DocumentReference conductMonthDocRef =
        FirebaseFirestore.instance.collection('CONDUCT_MONTH').doc(stdId);
    DocumentSnapshot conductSnapshot = await conductMonthDocRef.get();

    if (conductSnapshot.exists) {
      final conductData = conductSnapshot.data() as Map<String, dynamic>;
      final monthData = conductData['_month'] as Map<String, dynamic>;
      String monthString = time.split('-')[1];
      String monthKey = 'month${monthString.replaceFirst('0', '')}';

      if (monthData.containsKey(monthKey) &&
          monthData[monthKey] is List &&
          monthData[monthKey].length >= 2) {
        int currentPoints = int.parse(monthData[monthKey][0].toString());
        int updatedPoints = currentPoints + minusPoints;
        monthData[monthKey][0] = updatedPoints;
        await conductMonthDocRef.update({'_month': monthData});
      }
    }

    // Xóa MISTAKE_MONTH
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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có vi phạm nào'));
        }

        final items = snapshot.data!;
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.25,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                collapsedBackgroundColor: Colors.transparent,
                backgroundColor: Colors.grey.shade50,
                title: Text(
                  item.m_name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                iconColor: Colors.blueGrey,
                collapsedIconColor: Colors.grey,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Người ghi: ${item.acc_name}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thời gian: ${item.mm_time}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ButtonWidget(
                                title: 'Chỉnh sửa',
                                color: Colors.blue,
                                ontap: () => Navigator.of(context).pushNamed(
                                  MistakeEditMistakePage.routeName,
                                  arguments: PackageData(
                                    agrReq: item,
                                    agr2: studentDetailModel,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ButtonWidget(
                                title: 'Xóa',
                                color: Colors.redAccent,
                                ontap: () async {
                                  await _deleteItem(item);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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
