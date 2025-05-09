import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';

class AppBarContainer extends StatelessWidget {
  const AppBarContainer({
    super.key,
    required this.child,
    this.title,
    this.implementLeading = false,
    this.titleString,
  });

  final Widget child;
  final Widget? title;
  final String? titleString;
  final bool implementLeading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: 140,
            child: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              toolbarHeight: 140,
              backgroundColor: ColorApp.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              title: Container(
                height: 80,
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white, // Màu nền
                  borderRadius: BorderRadius.circular(10.0), // Độ bo tròn
                ),
                child: title ??
                    Row(
                      children: [
                        if (implementLeading)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  10,
                                ),
                              ),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              FontAwesomeIcons.arrowLeft,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  titleString ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
              ),
              flexibleSpace: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        // gradient: Gradients.defaultGradientBackground,
                        // borderRadius: BorderRadius.only(
                        //     bottomLeft: Radius.circular(35),
                        //     bottomRight: Radius.circular(35)),
                        ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 140,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ],
      ),
    );
  }
}
