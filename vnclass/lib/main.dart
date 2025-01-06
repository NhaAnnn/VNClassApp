import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/helper/local_storage_helper.dart';
import 'package:vnclass/common/routes/routes.dart';
import 'package:vnclass/firebase_options.dart';
import 'package:vnclass/modules/login/view/login_page.dart';

void main() async {
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StuApp',
      theme: ThemeData(
        primaryColor: ColorApp.primaryColor,
        // scaffoldBackgroundColor: ColorApp.primaryColor,
        // dialogBackgroundColor: ColorApp.primaryColor,
      ),
      routes: routes,
      home: const LoginPage(),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(),
//     );
//   }
// }
