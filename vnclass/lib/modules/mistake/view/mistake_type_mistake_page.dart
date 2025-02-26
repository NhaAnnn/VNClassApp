import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/widget/item_write_mistake.dart';

class MistakeTypeMistakePage extends StatefulWidget {
  const MistakeTypeMistakePage({super.key});
  static const String routeName = '/mistake_type_mistake_page';

  @override
  State<MistakeTypeMistakePage> createState() => _MistakeTypeMistakePageState();
}

class _MistakeTypeMistakePageState extends State<MistakeTypeMistakePage> {
  final MistakeController controller = MistakeController();
  StudentDetailModel? studentDetailModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentDetailModel =
        ModalRoute.of(context)!.settings.arguments as StudentDetailModel?;
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: studentDetailModel!.nameStudent,
      implementLeading: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: ItemWriteMistake(
            controller: controller,
            studentDetailModel: studentDetailModel,
          ),
        ),
      ),
    );
  }
}
