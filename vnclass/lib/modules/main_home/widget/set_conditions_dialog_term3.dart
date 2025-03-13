import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';

class SetConditionsDialogTerm3 extends StatefulWidget {
  const SetConditionsDialogTerm3({super.key});

  @override
  _SetConditionsDialogTerm3State createState() =>
      _SetConditionsDialogTerm3State();
}

class _SetConditionsDialogTerm3State extends State<SetConditionsDialogTerm3> {
  bool isEnabled = false;
  List<Map<String, String>> goodConditions = [];
  List<Map<String, String>> fairConditions = [];
  List<Map<String, String>> passConditions = [];
  List<Map<String, String>> failConditions = [];
  String? errorMessage;

  final List<String> rankOptions = ['Tốt', 'Khá', 'Đạt', 'Chưa Đạt'];
  final CollectionReference _setUpCollection =
      FirebaseFirestore.instance.collection('SET_UP');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu từ Firestore
  Future<void> _loadData() async {
    try {
      DocumentSnapshot doc = await _setUpCollection.doc('setTerm3').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          // Khi load dữ liệu, ta giữ isEnabled là false (vô hiệu chức năng thay đổi)
          isEnabled = false;
          goodConditions = _loadConditions(data['conditions']['good']);
          fairConditions = _loadConditions(data['conditions']['fair']);
          passConditions = _loadConditions(data['conditions']['pass']);
          failConditions = _loadConditions(data['conditions']['fail']);
        });
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Hàm hỗ trợ để tải danh sách điều kiện
  List<Map<String, String>> _loadConditions(dynamic conditions) {
    if (conditions == null || conditions is! List) return [];
    return conditions.map<Map<String, String>>((condition) {
      return {
        'hki': condition['hki'] ?? 'Tốt',
        'hkii': condition['hkii'] ?? 'Tốt',
      };
    }).toList();
  }

  // Lưu dữ liệu vào Firestore
  Future<void> _saveData() async {
    setState(() {
      errorMessage = null;
    });

    try {
      await _setUpCollection.doc('setTerm3').set({
        'isEnabled': isEnabled,
        'conditions': {
          'good': goodConditions
              .map((c) => {
                    'hki': c['hki'],
                    'hkii': c['hkii'],
                  })
              .toList(),
          'fair': fairConditions
              .map((c) => {
                    'hki': c['hki'],
                    'hkii': c['hkii'],
                  })
              .toList(),
          'pass': passConditions
              .map((c) => {
                    'hki': c['hki'],
                    'hkii': c['hkii'],
                  })
              .toList(),
          'fail': failConditions
              .map((c) => {
                    'hki': c['hki'],
                    'hkii': c['hkii'],
                  })
              .toList(),
        },
      });
      setState(() {
        errorMessage = 'Đã lưu dữ liệu thành công';
      });
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi lưu dữ liệu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 8,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      title: Center(
        child: Text(
          'Thiết lập điều kiện xếp loại rèn luyện học kỳ cả năm',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD81B60),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Kích hoạt thiết lập',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF263238),
                  ),
                ),
                value: isEnabled,
                onChanged: (value) => setState(() => isEnabled = value),
                activeColor: const Color(0xFFD81B60),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),
            _buildConditionSection(theme, 'Trường hợp "Tốt"', goodConditions),
            const SizedBox(height: 16),
            _buildConditionSection(theme, 'Trường hợp "Khá"', fairConditions),
            const SizedBox(height: 16),
            _buildConditionSection(theme, 'Trường hợp "Đạt"', passConditions),
            const SizedBox(height: 16),
            _buildConditionSection(
                theme, 'Trường hợp "Chưa Đạt"', failConditions),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFFD81B60),
                    ontap: () async {
                      await _saveData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonWidget(
                    title: 'Thoát',
                    color: const Color(0xFFD32F2F),
                    ontap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: errorMessage!.contains('thành công')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: errorMessage!.contains('thành công')
                        ? Colors.green[900]
                        : Colors.red[900],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng phần điều kiện
  Widget _buildConditionSection(
      ThemeData theme, String title, List<Map<String, String>> conditions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF455A64),
              ),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.plus,
                  size: 20, color: Color(0xFFD81B60)),
              onPressed: isEnabled
                  ? () {
                      setState(() {
                        conditions.add({
                          'hki': 'Tốt',
                          'hkii': 'Tốt',
                        });
                      });
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (conditions.isEmpty)
          const Text(
            'Chưa có trường hợp nào',
            style: TextStyle(fontSize: 14, color: Color(0xFF78909C)),
          )
        else
          ...conditions.map(
              (condition) => _buildConditionRow(theme, condition, conditions)),
      ],
    );
  }

  // Hàm xây dựng mỗi hàng điều kiện
  Widget _buildConditionRow(ThemeData theme, Map<String, String> condition,
      List<Map<String, String>> conditions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HKI',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                ),
                const SizedBox(height: 4),
                // Sử dụng IgnorePointer để vô hiệu hoá khi isEnabled == false
                IgnorePointer(
                  ignoring: !isEnabled,
                  child: DropMenuWidget<String>(
                    items: rankOptions,
                    hintText: 'HKI',
                    selectedItem: condition['hki'],
                    onChanged: (value) =>
                        setState(() => condition['hki'] = value!),
                    fillColor: Colors.white,
                    borderColor: const Color(0xFFE0E0E0),
                    textStyle: theme.textTheme.bodyMedium
                        ?.copyWith(color: const Color(0xFF263238)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HKII',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                ),
                const SizedBox(height: 4),
                IgnorePointer(
                  ignoring: !isEnabled,
                  child: DropMenuWidget<String>(
                    items: rankOptions,
                    hintText: 'HKII',
                    selectedItem: condition['hkii'],
                    onChanged: (value) =>
                        setState(() => condition['hkii'] = value!),
                    fillColor: Colors.white,
                    borderColor: const Color(0xFFE0E0E0),
                    textStyle: theme.textTheme.bodyMedium
                        ?.copyWith(color: const Color(0xFF263238)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(FontAwesomeIcons.trash,
                size: 20, color: Color(0xFFD32F2F)),
            onPressed: isEnabled
                ? () {
                    setState(() {
                      conditions.remove(condition);
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
