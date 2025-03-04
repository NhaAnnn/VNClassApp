import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/helper/local_storage_helper.dart';
import 'package:vnclass/firebase_options.dart';
import 'package:vnclass/modules/login/view/login_page.dart';
import 'package:vnclass/modules/main_home/views/user_screen.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/splash_screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (kDebugMode) print('Start init: ${DateTime.now()}');

    // Chỉ khởi tạo Hive, không mở box ngay
    await LocalStorageHelper.initLocalStorageHelper();
    if (kDebugMode) print('Hive init done: ${DateTime.now()}');

    await Future.wait<void>([
      NotificationService.initialize().then((_) =>
          kDebugMode ? print('Notification done: ${DateTime.now()}') : null),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .then((_) =>
              kDebugMode ? print('Firebase done: ${DateTime.now()}') : null),
    ]);

    if (kDebugMode) print('All done: ${DateTime.now()}');
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _getResponsiveLayout()),
      );
    }
  }

  Widget _getResponsiveLayout() {
    if (kIsWeb) {
      return LoginPage();
    } else if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return UserScreen();
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print('Splash screen build: ${DateTime.now()}');
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'StuApp',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
