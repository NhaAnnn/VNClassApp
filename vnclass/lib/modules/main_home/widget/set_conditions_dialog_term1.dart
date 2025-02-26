import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_widget.dart';

class SetConditionsDialogTerm1 extends StatefulWidget {
  const SetConditionsDialogTerm1({super.key});

  @override
  _SetConditionsDialogTerm1State createState() =>
      _SetConditionsDialogTerm1State();
}

class _SetConditionsDialogTerm1State extends State<SetConditionsDialogTerm1> {
  bool isEnabled = false; // Trạng thái bật/tắt của switch

  // Danh sách các trường hợp cho từng loại xếp loại
  List<Map<String, TextEditingController>> goodConditions = [];
  List<Map<String, TextEditingController>> fairConditions = [];
  List<Map<String, TextEditingController>> passConditions = [];
  List<Map<String, TextEditingController>> failConditions = [];

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
          'Thiết lập điều kiện xếp loại rèn luyện học kỳ 1',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF388E3C), // Xanh lá cho học kỳ 1
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Switch bật/tắt
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
                activeColor: const Color(0xFF388E3C),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),
            // Số lượng tháng cố định
            const Text(
              'Số lượng tháng là: 4',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF455A64),
              ),
            ),
            const SizedBox(height: 20),
            // Các trường hợp xếp loại
            _buildConditionSection('Trường hợp HK "Tốt"', goodConditions),
            const SizedBox(height: 16),
            _buildConditionSection('Trường hợp HK "Khá"', fairConditions),
            const SizedBox(height: 16),
            _buildConditionSection('Trường hợp HK "Đạt"', passConditions),
            const SizedBox(height: 16),
            _buildConditionSection('Trường hợp HK "Chưa Đạt"', failConditions),
            const SizedBox(height: 24),
            // Nút Lưu và Thoát
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFF388E3C),
                    ontap: isEnabled
                        ? () {
                            // In tất cả các trường hợp đã nhập
                            _printConditions();
                            // TODO: Thêm logic lưu dữ liệu nếu cần
                            Navigator.pop(context);
                          }
                        : null,
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
          ],
        ),
      ),
    );
  }

  // Hàm in tất cả các trường hợp đã nhập
  void _printConditions() {
    print('--- Các trường hợp xếp loại rèn luyện học kỳ 1 ---');

    if (goodConditions.isNotEmpty) {
      print('Trường hợp HK "Tốt":');
      for (var condition in goodConditions) {
        print(
            '  Tốt: ${condition['good']!.text}, Khá: ${condition['fair']!.text}, '
            'Đạt: ${condition['pass']!.text}, Chưa Đạt: ${condition['fail']!.text}');
      }
    }

    if (fairConditions.isNotEmpty) {
      print('Trường hợp HK "Khá":');
      for (var condition in fairConditions) {
        print(
            '  Tốt: ${condition['good']!.text}, Khá: ${condition['fair']!.text}, '
            'Đạt: ${condition['pass']!.text}, Chưa Đạt: ${condition['fail']!.text}');
      }
    }

    if (passConditions.isNotEmpty) {
      print('Trường hợp HK "Đạt":');
      for (var condition in passConditions) {
        print(
            '  Tốt: ${condition['good']!.text}, Khá: ${condition['fair']!.text}, '
            'Đạt: ${condition['pass']!.text}, Chưa Đạt: ${condition['fail']!.text}');
      }
    }

    if (failConditions.isNotEmpty) {
      print('Trường hợp HK "Chưa Đạt":');
      for (var condition in failConditions) {
        print(
            '  Tốt: ${condition['good']!.text}, Khá: ${condition['fair']!.text}, '
            'Đạt: ${condition['pass']!.text}, Chưa Đạt: ${condition['fail']!.text}');
      }
    }

    if (goodConditions.isEmpty &&
        fairConditions.isEmpty &&
        passConditions.isEmpty &&
        failConditions.isEmpty) {
      print('Chưa có trường hợp nào được nhập.');
    }
    print('---------------------------------------------');
  }

  // Hàm xây dựng phần điều kiện cho từng loại xếp loại
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
                  size: 20, color: Color(0xFF388E3C)),
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
        if (conditions.isEmpty && !isEnabled)
          const Text(
            'Chưa có trường hợp nào',
            style: TextStyle(fontSize: 14, color: Color(0xFF78909C)),
          )
        else
          // Truyền danh sách conditions vào _buildConditionRow
          ...conditions
              .map((condition) => _buildConditionRow(condition, conditions)),
      ],
    );
  }

  // Hàm xây dựng mỗi hàng điều kiện, nhận danh sách conditions để xóa
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
                      conditions.remove(
                          condition); // Xóa trường hợp từ danh sách cụ thể
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
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
                    const BorderSide(color: Color(0xFF388E3C), width: 2),
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
}
