import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:vnclass/web/account/account_create_acc_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/account_create_acc_page_web.dart';
import 'package:vnclass/web/account/account_edit_acc_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/account_edit_acc_page_web.dart';
import 'package:vnclass/web/account/account_main_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/account_main_page_web.dart';
// Import các tệp dành cho mobile
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
import 'package:vnclass/web/classes/class_view_web.dart';
import 'package:vnclass/web/conduct/conduct_view_web.dart';

// Import các tệp dành cho web (chỉ khi kIsWeb là true)

import 'package:vnclass/web/home_view_web.dart'
    if (kIsWeb) 'package:vnclass/web/home_view_web.dart';
import 'package:vnclass/web/login/login_web_page.dart'
    if (kIsWeb) 'package:vnclass/web/login/login_web_page.dart';
import 'package:vnclass/web/main_home/main_home_web_page.dart'
    if (kIsWeb) 'package:vnclass/web/main_home/main_home_web_page.dart';
import 'package:vnclass/web/mistake/mistake_class_detail_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/mistake/mistake_class_detail_page_web.dart';
import 'package:vnclass/web/mistake/mistake_edit_mistake_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/mistake/mistake_edit_mistake_page_web.dart';
import 'package:vnclass/web/mistake/mistake_main_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/mistake/mistake_main_page_web.dart';
import 'package:vnclass/web/mistake/mistake_type_mistake_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/mistake/mistake_type_mistake_page_web.dart';
import 'package:vnclass/web/mistake/mistake_view_mistake_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/mistake/mistake_view_mistake_page_web.dart';
import 'package:vnclass/web/mistake/mistake_write_mistake_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/mistake/mistake_write_mistake_page_web.dart';
import 'package:vnclass/web/set_up_mistake/user_change_type_mistake_screen_web.dart'
    if (kIsWeb) 'package:vnclass/web/set_up_mistake/user_change_type_mistake_screen_web.dart';
import 'package:vnclass/web/set_up_point/user_set_points_screen_web.dart'
    if (kIsWeb) 'package:vnclass/web/set_up_point/user_set_points_screen_web.dart';
import 'package:vnclass/web/setting/user_screen_web.dart'
    if (kIsWeb) 'package:vnclass/web/setting/user_screen_web.dart';

final Map<String, WidgetBuilder> routes = {
  // Routes chung cho cả mobile và web
  SplashScreen.routeName: (context) => const SplashScreen(),
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
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  StudentConductInfoMonth.routeName: (context) =>
      const StudentConductInfoMonth(),
  UserSetPointsScreen.routeName: (context) => const UserSetPointsScreen(),

  // Routes chỉ dành cho web (được thêm khi kIsWeb là true)
  if (kIsWeb) ...{
    AccountMainPageWeb.routeName: (context) => const AccountMainPageWeb(),
    AccountCreateAccPageWeb.routeName: (context) =>
        const AccountCreateAccPageWeb(),
    AccountEditAccPageWeb.routeName: (context) => const AccountEditAccPageWeb(),
    HomeViewWeb.routeName: (context) => const HomeViewWeb(),
    LoginWebPage.routeName: (context) => const LoginWebPage(),
    MainHomeWebPage.routeName: (context) => const MainHomeWebPage(),
    MistakeMainPageWeb.routeName: (context) => const MistakeMainPageWeb(),
    MistakeClassDetailPageWeb.routeName: (context) =>
        const MistakeClassDetailPageWeb(),
    MistakeTypeMistakePageWeb.routeName: (context) =>
        const MistakeTypeMistakePageWeb(),
    MistakeWriteMistakePageWeb.routeName: (context) =>
        const MistakeWriteMistakePageWeb(),
    UserScreenWeb.routeName: (context) => const UserScreenWeb(),
    UserChangeTypeMistakeScreenWeb.routeName: (context) =>
        const UserChangeTypeMistakeScreenWeb(),
    UserSetPointsScreenWeb.routeName: (context) =>
        const UserSetPointsScreenWeb(),
    MistakeViewMistakePageWeb.routeName: (context) =>
        const MistakeViewMistakePageWeb(),
    MistakeEditMistakePageWeb.routeName: (context) =>
        const MistakeEditMistakePageWeb(),
    ConductViewWeb.routeName: (context) => const ConductViewWeb(),
    ClassViewWeb.routeName: (context) => const ClassViewWeb(),
  },
};
