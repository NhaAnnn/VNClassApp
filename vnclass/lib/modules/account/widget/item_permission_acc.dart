import 'package:flutter/material.dart';

class ChecklistTab extends StatefulWidget {
  const ChecklistTab({super.key, required this.listA, required this.listB});
  final List<String> listA;
  final List<String> listB;

  @override
  _ChecklistTabState createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  late List<bool> checkedStatus;
  bool _isEditing = false; // Trạng thái chỉnh sửa

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái checkbox: nếu listB chứa mục đó thì đánh dấu true
    checkedStatus = List<bool>.generate(widget.listA.length, (index) {
      return widget.listB.contains(widget.listA[index]);
    });
  }

  /// Hàm chọn tất cả các mục
  void selectAll() {
    setState(() {
      checkedStatus = List<bool>.filled(widget.listA.length, true);
    });
  }

  /// Hàm bỏ chọn tất cả các mục
  void deselectAll() {
    setState(() {
      checkedStatus = List<bool>.filled(widget.listA.length, false);
    });
  }

  /// Hàm lưu thay đổi (ví dụ: in ra danh sách các mục được chọn)
  void saveChanges() {
    List<String> selectedItems = [];
    for (int i = 0; i < widget.listA.length; i++) {
      if (checkedStatus[i]) {
        selectedItems.add(widget.listA[i]);
      }
    }
    // In ra danh sách đã chọn trong terminal
    print("Các mục được chọn: $selectedItems");
    // Thực hiện các xử lý lưu dữ liệu khác nếu cần.
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề của tab
            const Center(
              child: Text(
                'Checklist trong Tab 2',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Widget chuyển đổi chế độ chỉnh sửa
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chế độ chỉnh sửa",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _isEditing,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _isEditing = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Danh sách các checkbox
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.listA.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(widget.listA[index]),
                  value: checkedStatus[index],
                  onChanged: _isEditing
                      ? (bool? value) {
                          setState(() {
                            checkedStatus[index] = value ?? false;
                          });
                        }
                      : null, // Nếu không ở chế độ chỉnh sửa thì disable thay đổi
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                );
              },
            ),
            const SizedBox(height: 20),
            // Nút điều khiển: Chọn tất cả, Bỏ chọn tất cả, Lưu thay đổi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isEditing ? selectAll : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Chọn tất cả"),
                ),
                ElevatedButton(
                  onPressed: _isEditing ? deselectAll : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Bỏ chọn tất cả"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isEditing ? saveChanges : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Lưu thay đổi",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
