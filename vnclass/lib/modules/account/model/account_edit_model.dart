import 'package:vnclass/modules/account/model/parent_model.dart';
import 'package:vnclass/modules/account/model/teacher_model.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/login/model/group_model.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/models/student_mistake_model.dart';

class AccountEditModel {
  final StudentMistakeModel? studentMistakeModel;
  final AccountModel accountModel;
  final StudentDetailModel? studentDetailModel;
  final GroupModel? groupModel;
  final ClassMistakeModel? classMistakeModel;
  final TeacherModel? teacherModel;
  final ParentModel? parentModel;

  AccountEditModel({
    required this.accountModel,
    this.studentDetailModel,
    this.studentMistakeModel,
    this.groupModel,
    this.classMistakeModel,
    this.parentModel,
    this.teacherModel,
  });

  @override
  String toString() {
    return 'AccountEditModel('
        'accountModel: ${accountModel.toString()}, '
        'studentDetailModel: ${studentDetailModel?.toString() ?? "null"}, '
        'studentMistakeModel: ${studentMistakeModel?.toString() ?? "null"}'
        'groupModel: ${groupModel.toString()}'
        'classMistakeModel: ${classMistakeModel.toString()}'
        'parentModel: ${parentModel.toString()}'
        'teacherModel: ${teacherModel.toString()}'
        ')';
  }
}
