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
  StudentDetailModel? studentDetailModel;
  String? month;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nhận tham số
    // studentDetailModel =
    //     ModalRoute.of(context)!.settings.arguments as StudentDetailModel?;

    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    studentDetailModel = arguments['studentDetailModel'];
    month = arguments['month'];
  }

  void _refreshItems() {
    setState(() {});
    // Thêm dòng này để đảm bảo cập nhật dữ liệu
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    String nameStudent = studentDetailModel!.nameStudent;
    return AppBarWidget(
      titleString: 'Vi phạm của $nameStudent',
      implementLeading: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.8, // Chiều cao của ListView
              child: SingleChildScrollView(
                child: ItemEditMistake(
                  studentDetailModel: studentDetailModel,
                  onItemDeleted: _refreshItems,
                  month: month,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
