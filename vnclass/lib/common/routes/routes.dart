import 'package:flutter/material.dart';
import 'package:vnclass/modules/account/view/account_creat_acc_page.dart';
import 'package:vnclass/modules/account/view/account_edit_acc_page.dart';
import 'package:vnclass/modules/account/view/account_main_page.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/view/student_info.dart';
import 'package:vnclass/modules/classes/class_detail/view/class_detail.dart';
import 'package:vnclass/modules/classes/view/all_classes.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info_month.dart';
import 'package:vnclass/modules/conduct/conduct_detail/view/conduct_detail.dart';
import 'package:vnclass/modules/conduct/view/all_conduct.dart';
import 'package:vnclass/modules/login/view/login_page.dart';
import 'package:vnclass/modules/main_home/views/main_home_page.dart';
import 'package:vnclass/modules/main_home/views/user_add_type_mistake_screen.dart';
import 'package:vnclass/modules/main_home/views/user_change_pass_screen.dart';
import 'package:vnclass/modules/main_home/views/user_change_type_mistake_screen.dart';
import 'package:vnclass/modules/main_home/views/user_set_points_screen.dart';
import 'package:vnclass/modules/mistake/view/mistake_class_detail_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_edit_mistake_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_main_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_type_mistake_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_view_mistake_page.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';
import 'package:vnclass/modules/notification/view/notification_screen.dart';
import 'package:vnclass/modules/report/view/report_main_page.dart';
import 'package:vnclass/modules/search/search_screen.dart';
import 'package:vnclass/modules/splash_screen/slpash_screen.dart';
import 'package:vnclass/web/home_view_web.dart';

final Map<String, WidgetBuilder> routes = {
  LoginPage.routeName: (context) => const LoginPage(),
  MainHomePage.routeName: (context) => const MainHomePage(),
  MistakeMainPage.routeName: (context) => const MistakeMainPage(),
  MistakeClassDetailPage.routeName: (context) => const MistakeClassDetailPage(),
  MistakeViewMistakePage.routeName: (context) => const MistakeViewMistakePage(),
  MistakeEditMistakePage.routeName: (context) => const MistakeEditMistakePage(),
  MistakeWriteMistakePage.routeName: (context) =>
      const MistakeWriteMistakePage(),
  MistakeTypeMistakePage.routeName: (context) => const MistakeTypeMistakePage(),
  ReportMainPage.routeName: (context) => const ReportMainPage(),
  AccountMainPage.routeName: (context) => const AccountMainPage(),
  AccountCreatAccPage.routeName: (context) => const AccountCreatAccPage(),
  AccountEditAccPage.routeName: (context) => const AccountEditAccPage(),
  UserChangePassScreen.routeName: (context) => const UserChangePassScreen(),
  UserChangeTypeMistakeScreen.routeName: (context) =>
      UserChangeTypeMistakeScreen(),
  UserAddTypeMistakeScreen.routeName: (context) => UserAddTypeMistakeScreen(),
  ClassDetail.routeName: (context) => const ClassDetail(),
  StudentInfo.routeName: (context) => const StudentInfo(),
  AllClasses.routeName: (context) => const AllClasses(),
  AllConduct.routeName: (context) => const AllConduct(),
  ConductDetail.routeName: (context) => const ConductDetail(),
  StudentConductInfo.routeName: (context) => const StudentConductInfo(),
  LoginPage.routeName: (context) => const LoginPage(),
  MainHomePage.routeName: (context) => const MainHomePage(),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  StudentConductInfoMonth.routeName: (context) =>
      const StudentConductInfoMonth(),
  HomeViewWeb.routeName: (context) => const HomeViewWeb(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  UserSetPointsScreen.routeName: (context) => const UserSetPointsScreen(),
};
