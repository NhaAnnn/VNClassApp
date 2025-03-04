import 'package:vnclass/modules/login/controller/account_controller.dart';

Future<List<String>> getDeviceToken(String accountID) async {
  List<String> tokens = await AccountController.fetchTokens(accountID);
  return tokens;
}
