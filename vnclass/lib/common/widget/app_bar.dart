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
      backgroundColor: Colors.white, // Consistent white background
      body: Stack(
        children: [
          // AppBar Section
          Container(
            height: 90, // Adjusted height
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500
                ], // Sky-blue gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                                borderRadius: BorderRadius.circular(
                                    8), // Slightly smaller radius
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.blue.shade200.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding:
                                  const EdgeInsets.all(8), // Reduced padding
                              child: Icon(
                                FontAwesomeIcons.arrowLeft, // Original icon
                                color: Colors.blue.shade700,
                                size: 16, // Smaller size
                              ),
                            ),
                          ),
                        if (implementLeading)
                          const SizedBox(width: 12), // Adjusted spacing
                        Expanded(
                          child: Text(
                            titleString ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18, // Kept smaller size
                              color: Colors.white, // Professional white
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (implementLeading)
                          const SizedBox(width: 28), // Adjusted spacing
                      ],
                    ),
              ),
            ),
          ),
          // Content Section
          Container(
            margin: const EdgeInsets.only(top: 90),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
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
