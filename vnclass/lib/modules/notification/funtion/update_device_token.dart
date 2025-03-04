import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';

Future<String?> updateToken(String accountID) async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String? token = await firebaseMessaging.getToken();
  await AccountController.updateToken(accountID, token!);
  return token;
}
