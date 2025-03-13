import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';
import 'package:vnclass/web/mistake/mistake_write_mistake_page_web.dart';

class ItemWriteMistakeWeb extends StatefulWidget {
  const ItemWriteMistakeWeb({
    super.key,
    required this.controller,
    this.studentDetailModel,
  });

  final MistakeController controller;
  final StudentDetailModel? studentDetailModel;

  @override
  ItemWriteMistakeWebState createState() => ItemWriteMistakeWebState();
}

class ItemWriteMistakeWebState extends State<ItemWriteMistakeWeb> {
  List<TypeMistakeModel>? items;
  List<TypeMistakeModel>? cachedData;

  @override
  void initState() {
    super.initState();
    _loadMistakeTypes();
  }

  Future<void> _loadMistakeTypes() async {
    final fetchedItems = await widget.controller.fetchMistakeTypes();
    setState(() {
      items = fetchedItems;
      cachedData = fetchedItems;
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

      await refreshData();
      Navigator.of(context).pop();
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

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách loại vi phạm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     // Logic thêm mới loại vi phạm (có thể mở dialog hoặc điều hướng)
                  //   },
                  //   icon: const Icon(Icons.add, size: 20),
                  //   label: const Text('Thêm mới'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xFF1E3A8A),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: displayData.length,
                    itemBuilder: (context, index) {
                      final type = displayData[index];
                      return ExpansionTile(
                        leading: const Icon(Icons.category,
                            color: Color(0xFF1976D2)),
                        title: Text(
                          type.nameType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        children: type.mistakes != null &&
                                type.mistakes!.isNotEmpty
                            ? type.mistakes!.map((mistake) {
                                return ListTile(
                                  leading: const Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: Colors.grey),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          mistake.nameMistake,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '-${mistake.minusPoint} điểm',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(
                                                FontAwesomeIcons.pen,
                                                size: 18,
                                                color: Color(0xFF1976D2)),
                                            onPressed: () async {
                                              await Navigator.pushNamed(
                                                context,
                                                MistakeWriteMistakePageWeb
                                                    .routeName,
                                                arguments: PackageData(
                                                  agrReq: mistake.nameMistake,
                                                  agr2: mistake,
                                                  agr3:
                                                      widget.studentDetailModel,
                                                  agr4: account,
                                                ),
                                              );
                                              await refreshData();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()
                            : [const SizedBox.shrink()],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Container(
          height: 60,
          color: Colors.grey.shade200,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Quay lại',
                style: TextStyle(color: Color(0xFF1E3A8A))),
          ),
        ],
      ),
    );
  }
}
