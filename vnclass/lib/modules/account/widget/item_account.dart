import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/view/account_edit_acc_page.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class ItemAccount extends StatelessWidget {
  const ItemAccount({super.key, this.accountModel, this.accountEditModel});

  final AccountModel? accountModel;
  final AccountEditModel? accountEditModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: _buildInfoSection(),
            ),
            const SizedBox(width: 12),
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          accountEditModel?.accountModel.accName ?? 'Không có tên',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          accountEditModel?.accountModel.userName ?? 'Không có tài khoản',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context: context,
          icon: FontAwesomeIcons.pen,
          color: const Color(0xFF1976D2), // Xanh đậm cho chỉnh sửa
          tooltip: 'Chỉnh sửa',
          onTap: () => _handleEdit(context),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context: context,
          icon: FontAwesomeIcons.trash,
          color: Colors.redAccent, // Đỏ cho xóa
          tooltip: 'Xóa',
          onTap: () => _handleDelete(context),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: color.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    if (accountEditModel != null) {
      Navigator.pushNamed(
        context,
        AccountEditAccPage.routeName,
        arguments: accountEditModel,
      );
    }
  }

  void _handleDelete(BuildContext context) {
    if (accountEditModel != null) {
      CustomDialogWidget.showConfirmationDialog(
        context,
        'Xác nhận xóa tài khoản?',
      );
    }
  }
}
