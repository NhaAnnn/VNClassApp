import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/report/widget/dialog_report.dart';

class ReportMainPage extends StatefulWidget {
  const ReportMainPage({super.key});
  static const String routeName = 'report_main_page';

  @override
  State<ReportMainPage> createState() => _ReportMainPageState();
}

class _ReportMainPageState extends State<ReportMainPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;
    // print('acc ${account!.goupID}');

    return AppBarWidget(
      implementLeading: true,
      titleString: 'Báo Cáo',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReportCard(
              context,
              title: 'Xuất Báo Cáo Vi Phạm Lớp Học',
              icon: Icons.people_outline,
              gradientColors: [
                const Color(0xFFE3F2FD),
                const Color(0xFFBBDEFB)
              ],
              accentColor: const Color(0xFF1976D2),
              onTap: () => _showReportDialog(context, 'class'),
            ),
            if (account!.goupID == 'banGH') ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _buildReportCard(
                context,
                title: 'Xuất Báo Cáo Vi Phạm Trường Học',
                icon: Icons.account_balance_outlined,
                gradientColors: [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFC8E6C9)
                ],
                accentColor: const Color(0xFF2E7D32),
                onTap: () => _showReportDialog(context, 'school'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors, // Gradient nhạt
          ),
          borderRadius: BorderRadius.circular(24), // Bo góc lớn hơn
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: accentColor.withOpacity(0.2),
            highlightColor: accentColor.withOpacity(0.1),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    child: Icon(
                      icon,
                      size: 36, // Giảm kích thước icon
                      color: accentColor, // Màu accent
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF263238), // Đen xám nhạt
                        fontSize: 18,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String reportType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogReport(reportType: reportType);
      },
    );
  }
}
