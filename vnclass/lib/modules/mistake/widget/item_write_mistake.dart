import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';

class ItemWriteMistake extends StatefulWidget {
  const ItemWriteMistake({
    super.key,
    required this.controller,
    this.studentDetailModel,
  });

  final MistakeController controller;
  final StudentDetailModel? studentDetailModel;

  @override
  ItemWriteMistakeState createState() => ItemWriteMistakeState();
}

class ItemWriteMistakeState extends State<ItemWriteMistake> {
  List<TypeMistakeModel>? items; // Dữ liệu hiện tại
  List<TypeMistakeModel>? cachedData; // Cache cục bộ

  @override
  void initState() {
    super.initState();
    _loadMistakeTypes();
  }

  Future<void> _loadMistakeTypes() async {
    final fetchedItems = await widget.controller.fetchMistakeTypes();
    setState(() {
      items = fetchedItems;
      cachedData = fetchedItems; // Lưu vào cache
    });
  }

  Future<void> refreshData() async {
    await _loadMistakeTypes();
  }

  Future<void> _updateTypeMistake(
      TypeMistakeModel typeModel, bool status) async {
    final updatedMistake = TypeMistakeModel(
      idType: typeModel.idType,
      nameType: typeModel.nameType,
      status: status,
    );

    try {
      await FirebaseFirestore.instance
          .collection('MISTAKE_TYPE')
          .doc(updatedMistake.idType)
          .update(updatedMistake.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );

      await refreshData(); // Làm mới dữ liệu sau khi cập nhật
      Navigator.of(context).pop(); // Đóng dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    return RefreshIndicator(
      onRefresh: refreshData,
      child: FutureBuilder<List<TypeMistakeModel>>(
        future: widget.controller.fetchMistakeTypes(),
        builder: (context, snapshot) {
          // Hiển thị dữ liệu cache nếu đang chờ và có cache
          final displayData =
              snapshot.connectionState == ConnectionState.waiting &&
                      cachedData != null
                  ? cachedData
                  : (snapshot.hasData ? snapshot.data : items);

          if (snapshot.connectionState == ConnectionState.waiting &&
              cachedData == null) {
            return _buildLoadingSkeleton();
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }
          if (displayData == null || displayData.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return ListView.builder(
            physics:
                const AlwaysScrollableScrollPhysics(), // Đảm bảo scroll được với RefreshIndicator
            shrinkWrap: true,
            itemCount: displayData.length,
            itemBuilder: (context, index) {
              var item = displayData[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.only(bottom: 16),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  leading: const Icon(Icons.category, color: Color(0xFF1976D2)),
                  title: Text(
                    item.nameType,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: item.mistakes!.map((mistake) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          MistakeWriteMistakePage.routeName,
                          arguments: PackageData(
                            agrReq: mistake.nameMistake,
                            agr2: mistake,
                            agr3: widget.studentDetailModel,
                            agr4: account,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 8,
                                child: Text(
                                  mistake.nameMistake,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      size: 20, color: Color(0xFF388E3C)),
                                  onPressed: () {
                                    // Thêm logic chỉnh sửa nếu cần
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3, // Giả lập 3 item skeleton
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Lỗi: $error', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: refreshData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
