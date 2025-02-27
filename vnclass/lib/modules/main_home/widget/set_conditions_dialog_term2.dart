import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/common/widget/button_widget.dart';

class SetConditionsDialogTerm2 extends StatefulWidget {
  const SetConditionsDialogTerm2({super.key});

  @override
  _SetConditionsDialogTerm2State createState() =>
      _SetConditionsDialogTerm2State();
}

class _SetConditionsDialogTerm2State extends State<SetConditionsDialogTerm2> {
  bool isEnabled = false;
  List<Map<String, TextEditingController>> goodConditions = [];
  List<Map<String, TextEditingController>> fairConditions = [];
  List<Map<String, TextEditingController>> passConditions = [];
  List<Map<String, TextEditingController>> failConditions = [];
  String? errorMessage;

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
      DocumentSnapshot doc = await _setUpCollection.doc('setTerm2').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          isEnabled = data['isEnabled'] ?? false;
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
  List<Map<String, TextEditingController>> _loadConditions(dynamic conditions) {
    if (conditions == null || conditions is! List) return [];
    return conditions.map<Map<String, TextEditingController>>((condition) {
      return {
        'good': TextEditingController(text: condition['good'] ?? ''),
        'fair': TextEditingController(text: condition['fair'] ?? ''),
        'pass': TextEditingController(text: condition['pass'] ?? ''),
        'fail': TextEditingController(text: condition['fail'] ?? ''),
      };
    }).toList();
  }

  // Lưu dữ liệu vào Firestore với kiểm tra tổng = 5
  Future<void> _saveData() async {
    setState(() {
      errorMessage = null;
    });

    if (isEnabled) {
      for (var conditions in [
        goodConditions,
        fairConditions,
        passConditions,
        failConditions
      ]) {
        for (var condition in conditions) {
          if (condition['good']!.text.isEmpty ||
              condition['fair']!.text.isEmpty ||
              condition['pass']!.text.isEmpty ||
              condition['fail']!.text.isEmpty) {
            setState(() {
              errorMessage = 'Vui lòng nhập đầy đủ các trường';
            });
            return;
          }
          try {
            int good = int.parse(condition['good']!.text);
            int fair = int.parse(condition['fair']!.text);
            int pass = int.parse(condition['pass']!.text);
            int fail = int.parse(condition['fail']!.text);
            int total = good + fair + pass + fail;
            if (total != 5) {
              setState(() {
                errorMessage = 'Tổng SL Tốt, Khá, Đạt, Chưa Đạt phải bằng 5';
              });
              return;
            }
          } catch (e) {
            setState(() {
              errorMessage = 'Dữ liệu phải là số nguyên hợp lệ';
            });
            return;
          }
        }
      }
    }

    try {
      await _setUpCollection.doc('setTerm2').set({
        'isEnabled': isEnabled,
        'conditions': {
          'good': goodConditions
              .map((c) => {
                    'good': c['good']!.text,
                    'fair': c['fair']!.text,
                    'pass': c['pass']!.text,
                    'fail': c['fail']!.text,
                  })
              .toList(),
          'fair': fairConditions
              .map((c) => {
                    'good': c['good']!.text,
                    'fair': c['fair']!.text,
                    'pass': c['pass']!.text,
                    'fail': c['fail']!.text,
                  })
              .toList(),
          'pass': passConditions
              .map((c) => {
                    'good': c['good']!.text,
                    'fair': c['fair']!.text,
                    'pass': c['pass']!.text,
                    'fail': c['fail']!.text,
                  })
              .toList(),
          'fail': failConditions
              .map((c) => {
                    'good': c['good']!.text,
                    'fair': c['fair']!.text,
                    'pass': c['pass']!.text,
                    'fail': c['fail']!.text,
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
          'Thiết lập điều kiện xếp loại rèn luyện học kỳ 2',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFBC02D),
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
                activeColor: const Color(0xFFFBC02D),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Số lượng tháng là: 5',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF455A64),
              ),
            ),
            const SizedBox(height: 20),
            _buildConditionSection('Trường hợp HK "Tốt"', goodConditions),
            const SizedBox(height: 16),
            _buildConditionSection('Trường hợp HK "Khá"', fairConditions),
            const SizedBox(height: 16),
            _buildConditionSection('Trường hợp HK "Đạt"', passConditions),
            const SizedBox(height: 16),
            _buildConditionSection('Trường hợp HK "Chưa Đạt"', failConditions),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFFFBC02D),
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
      String title, List<Map<String, TextEditingController>> conditions) {
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
                  size: 20, color: Color(0xFFFBC02D)),
              onPressed: isEnabled
                  ? () {
                      setState(() {
                        conditions.add({
                          'good': TextEditingController(),
                          'fair': TextEditingController(),
                          'pass': TextEditingController(),
                          'fail': TextEditingController(),
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
          ...conditions
              .map((condition) => _buildConditionRow(condition, conditions)),
      ],
    );
  }

  // Hàm xây dựng mỗi hàng điều kiện
  Widget _buildConditionRow(Map<String, TextEditingController> condition,
      List<Map<String, TextEditingController>> conditions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildNumberField('SL Tốt', condition['good']!),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildNumberField('SL Khá', condition['fair']!),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildNumberField('SL Đạt', condition['pass']!),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildNumberField('SL C.Đạt', condition['fail']!),
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

  // Hàm xây dựng ô nhập số
  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: TextField(
            controller: controller,
            enabled: isEnabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
            decoration: InputDecoration(
              filled: true,
              fillColor: isEnabled ? Colors.white : const Color(0xFFF5F7FA),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFBC02D), width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var condition in goodConditions) {
      condition['good']!.dispose();
      condition['fair']!.dispose();
      condition['pass']!.dispose();
      condition['fail']!.dispose();
    }
    for (var condition in fairConditions) {
      condition['good']!.dispose();
      condition['fair']!.dispose();
      condition['pass']!.dispose();
      condition['fail']!.dispose();
    }
    for (var condition in passConditions) {
      condition['good']!.dispose();
      condition['fair']!.dispose();
      condition['pass']!.dispose();
      condition['fail']!.dispose();
    }
    for (var condition in failConditions) {
      condition['good']!.dispose();
      condition['fair']!.dispose();
      condition['pass']!.dispose();
      condition['fail']!.dispose();
    }
    super.dispose();
  }
}
// {
//   "isEnabled": true,
//   "conditions": {
//     "good": [
//       {"good": "5", "fair": "0", "pass": "0", "fail": "0"}
//     ],
//     "fair": [
//       {"good": "3", "fair": "2", "pass": "0", "fail": "0"}
//     ],
//     "pass": [
//       {"good": "2", "fair": "2", "pass": "1", "fail": "0"}
//     ],
//     "fail": [
//       {"good": "0", "fair": "0", "pass": "0", "fail": "5"}
//     ]
//   }
// }
