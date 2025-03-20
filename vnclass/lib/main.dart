import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/helper/local_storage_helper.dart';
import 'package:vnclass/common/providers/class_mistake_provider.dart';
import 'package:vnclass/common/routes/routes.dart';
import 'package:vnclass/firebase_options.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
import 'package:vnclass/modules/main_home/controller/permission_provider.dart';
import 'package:vnclass/modules/main_home/controller/student_detail_provider.dart';
import 'package:vnclass/modules/main_home/controller/teacher_provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/notification/funtion/notification_change.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';
import 'package:vnclass/modules/splash_screen/slpash_screen.dart';
import 'package:vnclass/web/home_view_web.dart';
import 'package:vnclass/web/login/login_web_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await LocalStorageHelper.initLocalStorageHelper();
  await NotificationService.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => YearProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => StudentDetailProvider()),
        ChangeNotifierProvider(create: (_) => ClassMistakeProvider()),
        ChangeNotifierProvider(create: (context) => NotificationChange()),
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
      title: 'VnClass',
      theme: ThemeData(
        primaryColor: ColorApp.primaryColor,
      ),
      routes: routes,
      initialRoute: kIsWeb ? LoginWebPage.routeName : SplashScreen.routeName,
    );
  }
}
