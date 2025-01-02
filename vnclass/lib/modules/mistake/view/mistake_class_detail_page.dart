import 'package:flutter/material.dart';

class MistakeClassDetailPage extends StatefulWidget {
  const MistakeClassDetailPage({super.key});
  static const String routeName = '/mistake_class_detail_page';
  @override
  State<MistakeClassDetailPage> createState() => _MistakeClassDetailPageState();
}

class _MistakeClassDetailPageState extends State<MistakeClassDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
    );
  }
}
