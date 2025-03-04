import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/widget/item_edit_mistake.dart';

class MistakeViewMistakePage extends StatefulWidget {
  const MistakeViewMistakePage({super.key});
  static const String routeName = '/mistake_view_mistake_page';

  @override
  State<MistakeViewMistakePage> createState() => _MistakeViewMistakePageState();
}

class _MistakeViewMistakePageState extends State<MistakeViewMistakePage> {
  late StudentDetailModel studentDetailModel;
  late String month;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    studentDetailModel = args['studentDetailModel'] as StudentDetailModel;
    month = args['month'] as String;
  }

  void _refreshItems() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Vi phạm của ${studentDetailModel.nameStudent}',
      implementLeading: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ItemEditMistake(
          studentDetailModel: studentDetailModel,
          onItemDeleted: _refreshItems,
          month: month,
        ),
      ),
    );
  }
}
