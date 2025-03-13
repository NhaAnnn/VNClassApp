import 'package:flutter/material.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/web/mistake/item_write_mistake_web.dart';
import 'package:vnclass/web/sidebar_widget.dart';

class MistakeTypeMistakePageWeb extends StatefulWidget {
  const MistakeTypeMistakePageWeb({super.key});
  static const String routeName = '/mistake_type_mistake_page_web';

  @override
  State<MistakeTypeMistakePageWeb> createState() =>
      _MistakeTypeMistakePageWebState();
}

class _MistakeTypeMistakePageWebState extends State<MistakeTypeMistakePageWeb> {
  final MistakeController controller = MistakeController();
  StudentDetailModel? studentDetailModel;

  final Map<String, dynamic> menuItem = {
    'icon': Icons.warning,
    'label': 'Cập nhật vi phạm'
  }; // Sidebar chỉ có 1 mục

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentDetailModel =
        ModalRoute.of(context)!.settings.arguments as StudentDetailModel?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Sidebar sử dụng SidebarWidget
          SidebarWidget(
            appTitle: 'VNCLASS',
            menuItem: menuItem,
            isSelected: true,
            onItemTap: () {
              print('Đã nhấn: ${menuItem['label']}');
            },
          ),
          // Nội dung chính
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 250,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E3A8A).withOpacity(0.9),
                            const Color(0xFF3B82F6).withOpacity(0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Cập nhật vi phạm - ${studentDetailModel?.nameStudent ?? "Không xác định"}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nội dung
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ItemWriteMistakeWeb(
                              controller: controller,
                              studentDetailModel: studentDetailModel,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
