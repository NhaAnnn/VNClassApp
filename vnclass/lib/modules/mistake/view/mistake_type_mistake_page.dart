import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/widget/item_type_mistake.dart';

class MistakeTypeMistakePage extends StatefulWidget {
  const MistakeTypeMistakePage({super.key});
  static const String routeName = '/mistake_type_mistake_page';

  @override
  State<MistakeTypeMistakePage> createState() => _MistakeTypeMistakePageState();
}

class _MistakeTypeMistakePageState extends State<MistakeTypeMistakePage> {
  final MistakeController controller = MistakeController();

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Nguyễn Văn A xxxxx xxxxxxx',
      implementLeading: true,
      child: Column(
        children: [
          // Dùng Expanded để cho phép ListView cuộn
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.8, // Chiều cao của ListView
            child: SingleChildScrollView(
              child: ItemTypeMistake(
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
