import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/common/widget/button_widget.dart';

class SetPointsDialog extends StatefulWidget {
  const SetPointsDialog({super.key});

  @override
  _SetPointsDialogState createState() => _SetPointsDialogState();
}

class _SetPointsDialogState extends State<SetPointsDialog> {
  bool isEnabled = false;
  final TextEditingController _goodFromController = TextEditingController();
  final TextEditingController _goodToController = TextEditingController();
  final TextEditingController _fairFromController = TextEditingController();
  final TextEditingController _fairToController = TextEditingController();
  final TextEditingController _passFromController = TextEditingController();
  final TextEditingController _passToController = TextEditingController();
  final TextEditingController _failFromController = TextEditingController();
  final TextEditingController _failToController = TextEditingController();

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
      DocumentSnapshot doc = await _setUpCollection.doc('setPoint').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          isEnabled = false;
          _goodFromController.text = data['points']['good']['from'] ?? '';
          _goodToController.text = data['points']['good']['to'] ?? '';
          _fairFromController.text = data['points']['fair']['from'] ?? '';
          _fairToController.text = data['points']['fair']['to'] ?? '';
          _passFromController.text = data['points']['pass']['from'] ?? '';
          _passToController.text = data['points']['pass']['to'] ?? '';
          _failFromController.text = data['points']['fail']['from'] ?? '';
          _failToController.text = data['points']['fail']['to'] ?? '';
        });
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Lưu dữ liệu vào Firestore với kiểm tra dữ liệu
  Future<void> _saveData() async {
    // Kiểm tra xem các ô nhập có trống không
    if (_goodFromController.text.isEmpty ||
        _goodToController.text.isEmpty ||
        _fairFromController.text.isEmpty ||
        _fairToController.text.isEmpty ||
        _passFromController.text.isEmpty ||
        _passToController.text.isEmpty ||
        _failFromController.text.isEmpty ||
        _failToController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ các khoảng điểm')),
      );
      return;
    }

    // Kiểm tra dữ liệu có phải là số hợp lệ không
    try {
      int.parse(_goodFromController.text);
      int.parse(_goodToController.text);
      int.parse(_fairFromController.text);
      int.parse(_fairToController.text);
      int.parse(_passFromController.text);
      int.parse(_passToController.text);
      int.parse(_failFromController.text);
      int.parse(_failToController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dữ liệu phải là số nguyên hợp lệ')),
      );
      return;
    }

    try {
      await _setUpCollection.doc('setPoint').set({
        'points': {
          'good': {
            'from': _goodFromController.text,
            'to': _goodToController.text,
          },
          'fair': {
            'from': _fairFromController.text,
            'to': _fairToController.text,
          },
          'pass': {
            'from': _passFromController.text,
            'to': _passToController.text,
          },
          'fail': {
            'from': _failFromController.text,
            'to': _failToController.text,
          },
        },
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu dữ liệu thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu dữ liệu: $e')),
      );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Lưu',
                    color: const Color(0xFF1976D2),
                    ontap: isEnabled
                        ? () async {
                            await _saveData(); // Gọi hàm lưu dữ liệu
                            if (mounted) {
                              Navigator.pop(
                                  context); // Chỉ đóng dialog nếu thành công và widget còn tồn tại
                            }
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

  @override
  void dispose() {
    _goodFromController.dispose();
    _goodToController.dispose();
    _fairFromController.dispose();
    _fairToController.dispose();
    _passFromController.dispose();
    _passToController.dispose();
    _failFromController.dispose();
    _failToController.dispose();
    super.dispose();
  }
}
