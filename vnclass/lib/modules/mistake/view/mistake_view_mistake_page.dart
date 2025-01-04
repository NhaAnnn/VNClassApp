import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/mistake/widget/item_edit_mistake.dart';

class MistakeViewMistakePage extends StatefulWidget {
  const MistakeViewMistakePage({super.key});
  static const String routeName = '/mistake_view_mistake_page';

  @override
  State<MistakeViewMistakePage> createState() => _MistakeViewMistakePageState();
}

class _MistakeViewMistakePageState extends State<MistakeViewMistakePage> {
  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Vi phạm của XXX Nguyen Do CXXXXX',
      implementLeading: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.8, // Chiều cao của ListView
              child: SingleChildScrollView(
                child: ItemEditMistake(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
