import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/view/account_edit_acc_page.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class ItemAccount extends StatelessWidget {
  const ItemAccount({
    super.key,
    this.accountModel,
    this.accountEditModel,
    this.onDataChanged,
  });

  final AccountModel? accountModel;
  final AccountEditModel? accountEditModel;
  final Function(AccountEditModel?, bool)?
      onDataChanged; // Thêm tham số isDeleted

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
        if (accountEditModel?.accountModel.goupID == 'phuHuynh') ...[
          const Text(
            'PHHS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            (accountEditModel!.accountModel.accName)
                    .split(' - ')
                    .sublist(1)
                    .join(' - ') ??
                'Không có tên',
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
        ] else ...[
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
          color: const Color(0xFF1976D2),
          tooltip: 'Chỉnh sửa',
          onTap: () => _handleEdit(context),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context: context,
          icon: FontAwesomeIcons.trash,
          color: Colors.redAccent,
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
      ).then((result) {
        if (result != null &&
            result is AccountEditModel &&
            onDataChanged != null) {
          onDataChanged!(result, false); // Chỉnh sửa, không xóa
        }
      });
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if (accountEditModel == null) return;

    final String groupId = accountEditModel!.accountModel.goupID;
    final String accountId = accountEditModel!.accountModel.idAcc;

    try {
      if (groupId == 'banGH' || groupId == 'giaoVien') {
        await Future.wait([
          FirebaseFirestore.instance
              .collection('ACCOUNT')
              .doc(accountId)
              .delete(),
          FirebaseFirestore.instance
              .collection('TEACHER')
              .doc(accountId)
              .delete(),
        ]);
      } else if (groupId == 'hocSinh') {
        final studentDoc = await FirebaseFirestore.instance
            .collection('STUDENT')
            .doc(accountId)
            .get();
        final String? parentId = studentDoc.data()?['P_id'];

        final String? classId = accountEditModel!.studentDetailModel?.classID;
        if (classId != null) {
          final classDoc = await FirebaseFirestore.instance
              .collection('CLASS')
              .doc(classId)
              .get();
          if (classDoc.exists) {
            final currentAmount = classDoc.data()!['_amount'] as num? ?? 0;
            final newAmount = currentAmount > 0 ? currentAmount.toInt() - 1 : 0;
            await FirebaseFirestore.instance
                .collection('CLASS')
                .doc(classId)
                .update({'_amount': newAmount});
          }
        }

        await Future.wait([
          FirebaseFirestore.instance
              .collection('ACCOUNT')
              .doc(accountId)
              .delete(),
          FirebaseFirestore.instance
              .collection('STUDENT')
              .doc(accountId)
              .delete(),
          if (accountEditModel!.classMistakeModel?.academicYear != null)
            FirebaseFirestore.instance
                .collection('STUDENT_DETAIL')
                .doc(
                    '$accountId${accountEditModel!.classMistakeModel!.academicYear}')
                .delete(),
          if (accountEditModel!.classMistakeModel?.academicYear != null)
            FirebaseFirestore.instance
                .collection('CONDUCT_MONTH')
                .doc(
                    '$accountId${accountEditModel!.classMistakeModel!.academicYear}')
                .delete(),
          if (parentId != null)
            FirebaseFirestore.instance
                .collection('ACCOUNT')
                .doc(parentId)
                .delete(),
          if (parentId != null)
            FirebaseFirestore.instance
                .collection('PARENT')
                .doc(parentId)
                .delete(),
        ]);
      } else if (groupId == 'phuHuynh') {
        final studentQuery = await FirebaseFirestore.instance
            .collection('STUDENT')
            .where('P_id', isEqualTo: accountId)
            .get();
        final studentDocs = studentQuery.docs;

        await Future.wait([
          FirebaseFirestore.instance
              .collection('ACCOUNT')
              .doc(accountId)
              .delete(),
          FirebaseFirestore.instance
              .collection('PARENT')
              .doc(accountId)
              .delete(),
          ...studentDocs.map((studentDoc) async {
            final studentId = studentDoc.id;
            final studentDetailQuery = await FirebaseFirestore.instance
                .collection('STUDENT_DETAIL')
                .where('ST_id', isEqualTo: studentId)
                .get();
            final studentDetailDocs = studentDetailQuery.docs;

            if (studentDetailDocs.isNotEmpty) {
              final classId = studentDetailDocs.first.data()['Class_id'];
              final classDoc = await FirebaseFirestore.instance
                  .collection('CLASS')
                  .doc(classId)
                  .get();
              if (classDoc.exists) {
                final currentAmount = classDoc.data()!['_amount'] as num? ?? 0;
                final newAmount =
                    currentAmount > 0 ? currentAmount.toInt() - 1 : 0;
                await FirebaseFirestore.instance
                    .collection('CLASS')
                    .doc(classId)
                    .update({'_amount': newAmount});
              }
            }

            await Future.wait([
              FirebaseFirestore.instance
                  .collection('ACCOUNT')
                  .doc(studentId)
                  .delete(),
              FirebaseFirestore.instance
                  .collection('STUDENT')
                  .doc(studentId)
                  .delete(),
              ...studentDetailDocs.map((doc) => FirebaseFirestore.instance
                  .collection('STUDENT_DETAIL')
                  .doc(doc.id)
                  .delete()),
              ...studentDetailDocs.map((doc) => FirebaseFirestore.instance
                  .collection('CONDUCT_MONTH')
                  .doc(
                      '$studentId${doc.data()['Class_id'].substring(doc.data()['Class_id'].length - 4)}')
                  .delete()),
            ]);
          }),
        ]);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa tài khoản thành công!'),
          duration: Duration(seconds: 2),
        ),
      );
      if (onDataChanged != null) {
        onDataChanged!(accountEditModel, true); // Báo rằng tài khoản đã bị xóa
      }
    } catch (e) {
      print('Lỗi khi xóa tài khoản: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa tài khoản thất bại!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleDelete(BuildContext context) {
    if (accountEditModel != null) {
      CustomDialogWidget.showConfirmationDialog(
        context,
        'Xác nhận xóa tài khoản?',
        onTapOK: () async {
          await _deleteAccount(context);
          Navigator.of(context).pop(); // Đóng dialog
        },
      );
    }
  }
}
