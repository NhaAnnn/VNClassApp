import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/view/account_edit_acc_page.dart';
import 'package:vnclass/modules/account/widget/dialog_permisstion.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class ItemAccount extends StatelessWidget {
  const ItemAccount({super.key, this.accountModel, this.accountEditModel});

  final AccountModel? accountModel;
  final AccountEditModel? accountEditModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withAlpha(50), // Border color
          width: 2, // Border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 3), // Changes the position of the shadow
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClassRow('Tên người dùng:',
                      accountEditModel!.accountModel.accName),
                  _buildClassRow(
                      'Tài khoản:', accountEditModel!.accountModel.accName),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              // onTap: () => Navigator.of(context)
              //     .pushNamed(MistakeClassDetailPage.routeName),
              onTap: () {
                print('du lieu $accountEditModel');
                Navigator.of(context).pushNamed(
                  AccountEditAccPage.routeName,
                  arguments: accountEditModel,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  FontAwesomeIcons.pen,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => CustomDialogWidget.showConfirmationDialog(
                  context, 'Xác nhận xóa tài khoản?'),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  FontAwesomeIcons.trash,
                  size: 30,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
