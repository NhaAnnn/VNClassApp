import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_edit_mistake_page.dart';

class ItemEditMistake extends StatefulWidget {
  const ItemEditMistake({
    super.key,
    this.studentDetailModel,
    required this.onItemDeleted,
    this.month,
  });

  final StudentDetailModel? studentDetailModel;
  final VoidCallback onItemDeleted;
  final String? month;

  @override
  State<ItemEditMistake> createState() => _ItemEditMistakeState();
}

class _ItemEditMistakeState extends State<ItemEditMistake> {
  late Future<List<EditMistakeModel>> _itemsFuture;
  bool _isDeleting = false; // Biến trạng thái để theo dõi quá trình xóa

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fetchItems();
  }

  Future<List<EditMistakeModel>> _fetchItems() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MISTAKE_MONTH')
        .where('_month', isEqualTo: widget.month)
        .where('STD_id', isEqualTo: widget.studentDetailModel!.id)
        .get();

    return Future.wait(
      snapshot.docs.map((doc) => EditMistakeModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> _deleteItem(BuildContext context, EditMistakeModel item) async {
    setState(() {
      _isDeleting = true; // Bắt đầu hiển thị progress
    });

    try {
      final db = FirebaseFirestore.instance;
      final classRef =
          db.collection('CLASS').doc(widget.studentDetailModel?.classID);
      final conductRef = db.collection('CONDUCT_MONTH').doc(item.std_id);
      final studentRef = db.collection('STUDENT_DETAIL').doc(item.std_id);
      final mistakeRef = db.collection('MISTAKE_MONTH').doc(item.mm_id);

      await db.runTransaction((transaction) async {
        final classDoc = await transaction.get(classRef);
        final conductDoc = await transaction.get(conductRef);
        final setPointDoc = await db.collection('SET_UP').doc('setPoint').get();

        if (!classDoc.exists || !conductDoc.exists || !setPointDoc.exists) {
          throw Exception('Dữ liệu không tồn tại');
        }

        final classData = classDoc.data()!;
        final conductData = conductDoc.data()!;
        final monthData = conductData['_month'] as Map<String, dynamic>;
        final pointsData = setPointDoc.data()!['points'];

        int month = int.parse(item.mm_time.split('-')[1]);
        int minusPoints = item.mistake?.minusPoint ?? 0;
        String monthKey =
            'month${month.toString().padLeft(2, '0').substring(1)}';

        int numberOfMisALL =
            int.parse(classData['_numberOfMisAll'].toString()) - 1;
        transaction.update(classRef, {
          '_numberOfMisAll': numberOfMisALL.toString(),
          '_numberOfMisS2': (month >= 1 && month <= 5)
              ? (int.parse(classData['_numberOfMisS2'].toString()) - 1)
                  .toString()
              : classData['_numberOfMisS2'],
          '_numberOfMisS1': (month >= 9 && month <= 12)
              ? (int.parse(classData['_numberOfMisS1'].toString()) - 1)
                  .toString()
              : classData['_numberOfMisS1'],
        });

        if (monthData.containsKey(monthKey) &&
            monthData[monthKey].length >= 2) {
          int currentPoints = int.parse(monthData[monthKey][0].toString());
          int updatedPoints = currentPoints + minusPoints;

          String conductType = _determineConductType(updatedPoints, pointsData);
          monthData[monthKey] = [updatedPoints.toString(), conductType];
          transaction.update(conductRef, {'_month': monthData});
        }

        final updatedConduct = await conductRef.get();
        final allConductData =
            updatedConduct.data()!['_month'] as Map<String, dynamic>;
        final conductTerms = await _calculateConductTerms(allConductData);

        transaction.update(studentRef, {
          '_conductAllYear': conductTerms['allYear'],
          '_conductTerm1': conductTerms['term1'],
          '_conductTerm2': conductTerms['term2'],
        });

        transaction.delete(mistakeRef);
      });

      // Cập nhật danh sách local thay vì refresh toàn bộ
      setState(() {
        _itemsFuture = _itemsFuture.then(
            (items) => items.where((i) => i.mm_id != item.mm_id).toList());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa thành công')),
        );
      }
      widget.onItemDeleted(); // Gọi callback để thông báo xóa thành công
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false; // Kết thúc hiển thị progress
        });
      }
    }
  }

  String _determineConductType(int points, Map<String, dynamic> pointsData) {
    if (points >= int.parse(pointsData['good']['from']) &&
        points <= int.parse(pointsData['good']['to'])) {
      return 'Tốt';
    } else if (points >= int.parse(pointsData['fair']['from']) &&
        points <= int.parse(pointsData['fair']['to'])) {
      return 'Khá';
    } else if (points >= int.parse(pointsData['pass']['from']) &&
        points <= int.parse(pointsData['pass']['to'])) {
      return 'Đạt';
    }
    return 'Chưa Đạt';
  }

  Future<Map<String, String>> _calculateConductTerms(
      Map<String, dynamic> allConductData) async {
    final db = FirebaseFirestore.instance;
    final setTerm1Snap = await db.collection('SET_UP').doc('setTerm1').get();
    final setTerm2Snap = await db.collection('SET_UP').doc('setTerm2').get();
    final setTerm3Snap = await db.collection('SET_UP').doc('setTerm3').get();

    Map<String, int> term1Count = {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0};
    for (int i = 9; i <= 12; i++) {
      String key = 'month$i';
      if (allConductData.containsKey(key) && allConductData[key].length >= 2) {
        term1Count[allConductData[key][1]] =
            term1Count[allConductData[key][1]]! + 1;
      }
    }

    Map<String, int> term2Count = {'Tốt': 0, 'Khá': 0, 'Đạt': 0, 'Chưa Đạt': 0};
    for (int i = 1; i <= 5; i++) {
      String key = 'month$i';
      if (allConductData.containsKey(key) && allConductData[key].length >= 2) {
        term2Count[allConductData[key][1]] =
            term2Count[allConductData[key][1]]! + 1;
      }
    }

    String term1 = setTerm1Snap.exists
        ? _determineConduct(setTerm1Snap.data()!['conditions'], term1Count)
        : 'Chưa Đạt';
    String term2 = setTerm2Snap.exists
        ? _determineConduct(setTerm2Snap.data()!['conditions'], term2Count)
        : 'Chưa Đạt';
    String allYear = setTerm3Snap.exists
        ? _determineAllYear(setTerm3Snap.data()!['conditions'], term1, term2)
        : 'Chưa Đạt';

    return {'term1': term1, 'term2': term2, 'allYear': allYear};
  }

  String _determineConduct(
      Map<String, dynamic> conditions, Map<String, int> counts) {
    for (var type in ['good', 'fair', 'pass', 'fail']) {
      for (var condition in conditions[type]) {
        if (counts['Tốt'] == int.parse(condition['good']) &&
            counts['Khá'] == int.parse(condition['fair']) &&
            counts['Đạt'] == int.parse(condition['pass']) &&
            counts['Chưa Đạt'] == int.parse(condition['fail'])) {
          return type == 'good'
              ? 'Tốt'
              : type == 'fair'
                  ? 'Khá'
                  : type == 'pass'
                      ? 'Đạt'
                      : 'Chưa Đạt';
        }
      }
    }
    return 'Chưa Đạt';
  }

  String _determineAllYear(
      Map<String, dynamic> conditions, String term1, String term2) {
    for (var type in ['good', 'fair', 'pass', 'fail']) {
      for (var condition in conditions[type]) {
        if (condition['hki'] == term1 && condition['hkii'] == term2) {
          return type == 'good'
              ? 'Tốt'
              : type == 'fair'
                  ? 'Khá'
                  : type == 'pass'
                      ? 'Đạt'
                      : 'Chưa Đạt';
        }
      }
    }
    return 'Chưa Đạt';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EditMistakeModel>>(
      future: _itemsFuture,
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
            return _buildItemCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, EditMistakeModel item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        backgroundColor: Colors.grey.shade50,
        title: Text(
          item.m_name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Người ghi: ${item.acc_name}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Thời gian: ${item.mm_time}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        title: 'Chỉnh sửa',
                        color: Colors.blue,
                        ontap: () => Navigator.of(context)
                            .pushNamed(
                              MistakeEditMistakePage.routeName,
                              arguments: PackageData(
                                  agrReq: item,
                                  agr2: widget.studentDetailModel),
                            )
                            .then((_) => setState(() {
                                  _itemsFuture =
                                      _fetchItems(); // Refresh sau khi chỉnh sửa
                                })),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ButtonWidget(
                        title: 'Xóa',
                        color: Colors.redAccent,
                        ontap: _isDeleting
                            ? null
                            : () => _deleteItem(context, item),
                        child: _isDeleting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
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
  }
}
