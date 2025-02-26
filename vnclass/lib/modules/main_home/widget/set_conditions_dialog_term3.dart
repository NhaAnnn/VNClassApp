import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';

class SetConditionsDialogTerm3 extends StatefulWidget {
  const SetConditionsDialogTerm3({super.key});

  @override
  _SetConditionsDialogTerm3State createState() =>
      _SetConditionsDialogTerm3State();
}

class _SetConditionsDialogTerm3State extends State<SetConditionsDialogTerm3> {
  bool isEnabled = false; // Trạng thái bật/tắt của switch

  // Danh sách các trường hợp cho từng loại xếp loại
  List<Map<String, String>> goodConditions = [];
  List<Map<String, String>> fairConditions = [];
  List<Map<String, String>> passConditions = [];
  List<Map<String, String>> failConditions = [];

  // Danh sách tùy chọn cho DropMenuWidget
  final List<String> rankOptions = ['Tốt', 'Khá', 'Đạt', 'Chưa Đạt'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lấy theme từ context trong build

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
            color: const Color(0xFFD81B60), // Hồng đậm cho cả năm
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
                activeColor: const Color(0xFFD81B60),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),
            // Các trường hợp xếp loại
            _buildConditionSection(theme, 'Trường hợp "Tốt"', goodConditions),
            const SizedBox(height: 16),
            _buildConditionSection(theme, 'Trường hợp "Khá"', fairConditions),
            const SizedBox(height: 16),
            _buildConditionSection(theme, 'Trường hợp "Đạt"', passConditions),
            const SizedBox(height: 16),
            _buildConditionSection(
                theme, 'Trường hợp "Chưa Đạt"', failConditions),
            const SizedBox(height: 24),
            // Nút Lưu và Thoát
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFFD81B60),
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
    print('--- Các trường hợp xếp loại rèn luyện học kỳ cả năm ---');

    if (goodConditions.isNotEmpty) {
      print('Trường hợp "Tốt":');
      for (var condition in goodConditions) {
        print('  HKI: ${condition['hki']}, HKII: ${condition['hkii']}');
      }
    }

    if (fairConditions.isNotEmpty) {
      print('Trường hợp "Khá":');
      for (var condition in fairConditions) {
        print('  HKI: ${condition['hki']}, HKII: ${condition['hkii']}');
      }
    }

    if (passConditions.isNotEmpty) {
      print('Trường hợp "Đạt":');
      for (var condition in passConditions) {
        print('  HKI: ${condition['hki']}, HKII: ${condition['hkii']}');
      }
    }

    if (failConditions.isNotEmpty) {
      print('Trường hợp "Chưa Đạt":');
      for (var condition in failConditions) {
        print('  HKI: ${condition['hki']}, HKII: ${condition['hkii']}');
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
                          'hki': 'Tốt', // Giá trị mặc định
                          'hkii': 'Tốt', // Giá trị mặc định
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
                DropMenuWidget<String>(
                  items: rankOptions,
                  hintText: 'HKI',
                  selectedItem: condition['hki'],
                  onChanged: isEnabled
                      ? (value) => setState(() => condition['hki'] = value!)
                      : null,
                  fillColor: Colors.white,
                  borderColor: const Color(0xFFE0E0E0),
                  textStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF263238)),
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
                DropMenuWidget<String>(
                  items: rankOptions,
                  hintText: 'HKII',
                  selectedItem: condition['hkii'],
                  onChanged: isEnabled
                      ? (value) => setState(() => condition['hkii'] = value!)
                      : null,
                  fillColor: Colors.white,
                  borderColor: const Color(0xFFE0E0E0),
                  textStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF263238)),
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
                      conditions
                          .remove(condition); // Xóa trường hợp từ danh sách
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
