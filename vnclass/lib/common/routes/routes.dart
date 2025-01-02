import 'package:flutter/material.dart';
import 'package:vnclass/modules/login/view/login_page.dart';
import 'package:vnclass/modules/main_home/views/main_home_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_class_detail_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_main_page.dart';

final Map<String, WidgetBuilder> routes = {
  LoginPage.routeName: (context) => const LoginPage(),
  MainHomePage.routeName: (context) => const MainHomePage(),
  MistakeMainPage.routeName: (context) => const MistakeMainPage(),
  MistakeClassDetailPage.routeName: (context) => const MistakeClassDetailPage(),
};
