import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/helper/local_storage_helper.dart';
import 'package:vnclass/common/routes/routes.dart';
import 'package:vnclass/firebase_options.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/login/view/login_page.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/main_home/views/help_screen.dart';
import 'package:vnclass/modules/main_home/views/main_home_page.dart';
import 'package:vnclass/modules/main_home/views/user_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:vnclass/modules/notification/funtion/notification_change.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';

void main() async {
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();
  await NotificationService.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProvider(
            create: (_) => YearProvider()), // Thêm YearProvider

        ChangeNotifierProvider(
          create: (context) =>
              NotificationChange(), // Khởi tạo NotificationChange
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StuApp',
      theme: ThemeData(
        primaryColor: ColorApp.primaryColor,
      ),
      routes: routes,
      home: _getResponsiveLayout(),
    );
  }

  // Hàm để quyết định layout dựa trên nền tảng
  Widget _getResponsiveLayout() {
    if (kIsWeb) {
      return LoginPage(); // Giao diện cho web
    } else if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return UserScreen(); // Giao diện cho desktop
    } else {
      return const LoginPage(); // Giao diện cho di động
    }
  }
}
