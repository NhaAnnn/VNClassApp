import 'package:flutter/material.dart';

class TabBarListAcc extends StatelessWidget {
  const TabBarListAcc({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Từ file Excel'),
              Tab(text: 'Tạo thủ công'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildExcelImport(),
                _buildManualInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcelImport() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.upload_file, size: 50),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Tải file mẫu'),
        ),
        const SizedBox(height: 16),
        const Text('Kéo thả file Excel vào đây hoặc'),
        TextButton(
          onPressed: () {},
          child: const Text('Chọn file'),
        ),
      ],
    );
  }

  Widget _buildManualInput() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Số lượng tài khoản'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Tiền tố tên đăng nhập'),
        ),
        const SizedBox(height: 16),
        const Text('Quyền hạn:'),
        ...['User', 'Admin', 'Manager'].map((role) => CheckboxListTile(
              title: Text(role),
              value: false,
              onChanged: (v) {},
            )),
      ],
    );
  }
}
