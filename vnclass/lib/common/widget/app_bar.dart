import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.child,
    this.title,
    this.implementLeading = false,
    this.titleString,
    this.onback,
  });

  final Widget child;
  final Widget? title;
  final String? titleString;
  final bool implementLeading;
  final Function? onback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          const Color(0xFFF5F7FA), // Nền tổng thể xám nhạt hơi xanh
      body: Stack(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFF1E90FF), // Xanh da trời đơn sắc
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x331E90FF), // Bóng xanh nhạt
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                elevation: 0,
                toolbarHeight: 90,
                backgroundColor: Colors.transparent,
                title: title ??
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (implementLeading)
                          GestureDetector(
                            onTap: () {
                              if (onback != null) onback!();
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                FontAwesomeIcons.arrowLeft,
                                color: Color(0xFF1E90FF), // Xanh da trời
                                size: 16,
                              ),
                            ),
                          ),
                        if (implementLeading) const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            titleString ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (implementLeading) const SizedBox(width: 28),
                      ],
                    ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 90),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A1E90FF), // Bóng xanh nhạt
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
