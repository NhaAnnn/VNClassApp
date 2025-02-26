import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/main_home/widget/set_conditions_dialog_term1.dart';
import 'package:vnclass/modules/main_home/widget/set_conditions_dialog_term2.dart'; // Giả định file này tồn tại
import 'package:vnclass/modules/main_home/widget/set_conditions_dialog_term3.dart';
import 'package:vnclass/modules/main_home/widget/user_set_points_dialog.dart';

class UserSetPointsScreen extends StatefulWidget {
  const UserSetPointsScreen({super.key});
  static const String routeName = '/user_set_points_screen';

  @override
  State<UserSetPointsScreen> createState() => _UserSetPointsScreenState();
}

class _UserSetPointsScreenState extends State<UserSetPointsScreen> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'Thiết lập mức điểm của các loại điểm rèn luyện',
      'icon': FontAwesomeIcons.listCheck,
      'color': const Color(0xFF1976D2),
    },
    {
      'title': 'Thiết lập điều kiện xếp loại điểm rèn luyện học kỳ 1',
      'icon': FontAwesomeIcons.chartBar,
      'color': const Color(0xFF388E3C),
    },
    {
      'title': 'Thiết lập điều kiện xếp loại điểm rèn luyện học kỳ 2',
      'icon': FontAwesomeIcons.chartLine,
      'color': const Color(0xFFFBC02D),
      'onTap': () {
        // TODO: Thêm logic khi nhấn vào mục này nếu không dùng dialog
        print('Thiết lập điều kiện học kỳ 2');
      },
    },
    {
      'title': 'Thiết lập điều kiện xếp loại điểm rèn luyện học kỳ cả năm',
      'icon': FontAwesomeIcons.chartPie,
      'color': const Color(0xFFD81B60),
      'onTap': () {
        // TODO: Thêm logic khi nhấn vào mục này nếu không dùng dialog
        print('Thiết lập điều kiện cả năm');
      },
    },
  ];

  void _showPointsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SetPointsDialog(),
    );
  }

  void _showConditionsDialogTerm1(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SetConditionsDialogTerm1(),
    );
  }

  void _showConditionsDialogTerm2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SetConditionsDialogTerm2(),
    );
  }

  void _showConditionsDialogTerm3(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const SetConditionsDialogTerm3(), // Giả định dialog này tồn tại
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBarWidget(
      titleString: 'Thiết lập mức điểm',
      implementLeading: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.map((item) {
            return _buildCard(
              item,
              onTap: item['title'] ==
                      'Thiết lập mức điểm của các loại điểm rèn luyện'
                  ? () => _showPointsDialog(context)
                  : item['title'] ==
                          'Thiết lập điều kiện xếp loại điểm rèn luyện học kỳ 1'
                      ? () => _showConditionsDialogTerm1(context)
                      : item['title'] ==
                              'Thiết lập điều kiện xếp loại điểm rèn luyện học kỳ 2'
                          ? () => _showConditionsDialogTerm2(context)
                          : item['title'] ==
                                  'Thiết lập điều kiện xếp loại điểm rèn luyện học kỳ cả năm'
                              ? () => _showConditionsDialogTerm3(context)
                              : item['onTap'] as VoidCallback?,
            );
          }).toList(),
        ),
      ),
    );
  }

  // Hàm xây dựng mỗi card (không có mũi tên)
  Widget _buildCard(Map<String, dynamic> item, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 28,
                  color: item['color'] as Color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF263238),
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
