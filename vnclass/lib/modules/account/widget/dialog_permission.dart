import 'package:flutter/material.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';

class DialogPermission extends StatelessWidget {
  final AccountEditModel accountEditModel;

  const DialogPermission({super.key, required this.accountEditModel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quyền'),
      content: Text('Quyền cho ${accountEditModel.accountModel.accName}'),
      actions: [
        TextButton(
          child: const Text('Đóng'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
