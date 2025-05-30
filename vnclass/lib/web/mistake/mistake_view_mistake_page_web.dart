import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_edit_mistake_page.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';
import 'package:vnclass/web/mistake/mistake_edit_mistake_page_web.dart';
import 'package:vnclass/web/sidebar_widget.dart';

class MistakeViewMistakePageWeb extends StatefulWidget {
  const MistakeViewMistakePageWeb({super.key});
  static const String routeName = '/mistake_view_mistake_page_web';

  @override
  State<MistakeViewMistakePageWeb> createState() =>
      _MistakeViewMistakePageWebState();
}

class _MistakeViewMistakePageWebState extends State<MistakeViewMistakePageWeb> {
  late StudentDetailModel studentDetailModel;
  late String month;
  late Future<List<EditMistakeModel>> _itemsFuture;
  bool _isDeleting = false;

  final Map<String, dynamic> menuItem = {
    'icon': FontAwesomeIcons.eye,
    'label': 'Xem vi phạm'
  }; // Sidebar chỉ có 1 mục

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    studentDetailModel = args['studentDetailModel'] as StudentDetailModel;
    month = args['month'] as String;
    _itemsFuture = _fetchItems();
  }

  Future<List<EditMistakeModel>> _fetchItems() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MISTAKE_MONTH')
        .where('_month', isEqualTo: month)
        .where('STD_id', isEqualTo: studentDetailModel.id)
        .get();

    return Future.wait(
      snapshot.docs.map((doc) => EditMistakeModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> _deleteItem(BuildContext context, EditMistakeModel item) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      final classRef = db.collection('CLASS').doc(studentDetailModel.classID);
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

        int monthNum = int.parse(item.mm_time.split('-')[1]);
        int minusPoints = item.mistake?.minusPoint ?? 0;
        String monthKey =
            'month${monthNum.toString().padLeft(2, '0').substring(1)}';

        int numberOfMisALL =
            int.parse(classData['_numberOfMisAll'].toString()) - 1;
        transaction.update(classRef, {
          '_numberOfMisAll': numberOfMisALL.toString(),
          '_numberOfMisS2': (monthNum >= 1 && monthNum <= 5)
              ? (int.parse(classData['_numberOfMisS2'].toString()) - 1)
                  .toString()
              : classData['_numberOfMisS2'],
          '_numberOfMisS1': (monthNum >= 9 && monthNum <= 12)
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

      setState(() {
        _itemsFuture = _itemsFuture.then(
            (items) => items.where((i) => i.mm_id != item.mm_id).toList());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa thành công')),
        );
      }

      String accid =
          await NotificationController.fetchAccIdFromStudentDetail(item.std_id);
      List<String> deviceTokens = await AccountController.fetchTokens(accid);
      await NotificationService.sendNotification(
        accid,
        deviceTokens,
        'Thông báo vi phạm',
        'Một vi phạm của bạn đã được xóa: Vi phạm ${item.m_name} vào ${item.mm_time} đã được xóa',
      );
      await NotificationController.createNotification(
        accid,
        'Thông báo vi phạm',
        'Một vi phạm của bạn đã được xóa: Vi phạm ${item.m_name} vào ${item.mm_time} đã được xóa',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Sidebar
          SidebarWidget(
            appTitle: 'Ứng dụng của tôi',
            menuItem: menuItem,
            isSelected: true,
            onItemTap: () {
              print('Đã nhấn: ${menuItem['label']}');
            },
          ),
          // Nội dung chính
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 250,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E3A8A).withOpacity(0.9),
                            const Color(0xFF3B82F6).withOpacity(0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Vi phạm của ${studentDetailModel.nameStudent}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bảng dữ liệu
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: Column(
                            children: [
                              // Tiêu đề bảng
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: _buildHeaderText('Tên vi phạm')),
                                    Expanded(
                                        flex: 2,
                                        child: _buildHeaderText('Người ghi')),
                                    Expanded(
                                        flex: 2,
                                        child: _buildHeaderText('Thời gian')),
                                    Expanded(
                                        flex: 1,
                                        child: _buildHeaderText('Chỉnh sửa')),
                                    Expanded(
                                        flex: 1,
                                        child: _buildHeaderText('Xóa')),
                                  ],
                                ),
                              ),
                              // Dữ liệu bảng
                              Expanded(
                                child: FutureBuilder<List<EditMistakeModel>>(
                                  future: _itemsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildLoadingSkeleton();
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Lỗi: ${snapshot.error}'));
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('Không có vi phạm nào'));
                                    }

                                    final items = snapshot.data!;
                                    return ListView.separated(
                                      itemCount: items.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                              height: 1,
                                              color: Colors.grey.shade200),
                                      itemBuilder: (context, index) {
                                        return _buildMistakeRow(
                                            context, items[index]);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildMistakeRow(BuildContext context, EditMistakeModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.m_name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.acc_name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.mm_time,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0288D1).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(FontAwesomeIcons.pen,
                      size: 18, color: Color(0xFF0288D1)),
                ),
                onPressed: () => Navigator.of(context)
                    .pushNamed(
                      MistakeEditMistakePageWeb.routeName,
                      arguments:
                          PackageData(agrReq: item, agr2: studentDetailModel),
                    )
                    .then((_) => setState(() {
                          _itemsFuture = _fetchItems();
                        })),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Color(0xFFD32F2F),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(FontAwesomeIcons.trash,
                          size: 18, color: Color(0xFFD32F2F)),
                ),
                onPressed: _isDeleting
                    ? null
                    : () async {
                        await _deleteItem(context, item);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 2,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 2,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 1,
                child: Container(height: 20, color: Colors.grey.shade200)),
            const SizedBox(width: 16),
            Expanded(
                flex: 1,
                child: Container(height: 20, color: Colors.grey.shade200)),
          ],
        ),
      ),
    );
  }
}
