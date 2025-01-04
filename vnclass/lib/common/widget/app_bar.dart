import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
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
            height: 100,
            child: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              toolbarHeight: 100,
              backgroundColor: ColorApp.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              title: title ??
                  Row(
                    children: [
                      if (implementLeading)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
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
                        ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleString ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 100,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: child,
          ),
        ],
      ),
    );
  }
}
