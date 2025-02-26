import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';

class SetPointsDialog extends StatefulWidget {
  const SetPointsDialog({super.key});

  @override
  _SetPointsDialogState createState() => _SetPointsDialogState();
}

class _SetPointsDialogState extends State<SetPointsDialog> {
  bool isEnabled = false; // Trạng thái bật/tắt của switch
  final TextEditingController _goodFromController = TextEditingController();
  final TextEditingController _goodToController = TextEditingController();
  final TextEditingController _fairFromController = TextEditingController();
  final TextEditingController _fairToController = TextEditingController();
  final TextEditingController _passFromController = TextEditingController();
  final TextEditingController _passToController = TextEditingController();
  final TextEditingController _failFromController = TextEditingController();
  final TextEditingController _failToController = TextEditingController();

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
          'Thiết lập mức điểm rèn luyện',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1976D2),
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
                activeColor: const Color(0xFF1976D2),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),
            // Các mức điểm
            _buildPointRangeRow(
                'Mức "Tốt"', _goodFromController, _goodToController),
            const SizedBox(height: 16),
            _buildPointRangeRow(
                'Mức "Khá"', _fairFromController, _fairToController),
            const SizedBox(height: 16),
            _buildPointRangeRow(
                'Mức "Đạt"', _passFromController, _passToController),
            const SizedBox(height: 16),
            _buildPointRangeRow(
                'Mức "Chưa Đạt"', _failFromController, _failToController),
            const SizedBox(height: 24),
            // Nút Lưu và Thoát
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFF1976D2),
                    ontap: isEnabled
                        ? () {
                            // TODO: Thêm logic lưu dữ liệu
                            print('Lưu dữ liệu mức điểm');
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

  // Hàm xây dựng hàng nhập khoảng điểm
  Widget _buildPointRangeRow(String label, TextEditingController fromController,
      TextEditingController toController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF455A64),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text(
                    'Từ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF78909C)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fromController,
                      enabled: isEnabled,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF263238)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isEnabled ? Colors.white : const Color(0xFFF5F7FA),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF1976D2), width: 2),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0), width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  const Text(
                    'Đến',
                    style: TextStyle(fontSize: 14, color: Color(0xFF78909C)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: toController,
                      enabled: isEnabled,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF263238)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isEnabled ? Colors.white : const Color(0xFFF5F7FA),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF1976D2), width: 2),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0), width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
