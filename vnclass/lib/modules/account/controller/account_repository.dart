import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/model/parent_model.dart';
import 'package:vnclass/modules/account/model/teacher_model.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/login/model/group_model.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/models/student_mistake_model.dart';

class AccountRepository {
  final FirebaseFirestore firestore;

  AccountRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<AccountEditModel>> fetchAccountsEditByGroup1(
      String idGroup) async {
    try {
      // Lấy danh sách account
      final accountSnapshot = await firestore
          .collection('ACCOUNT')
          .where('_groupID', isEqualTo: idGroup)
          .get();

      if (accountSnapshot.docs.isEmpty) return [];

      // Chuẩn bị danh sách IDs và dữ liệu
      final accountIds = accountSnapshot.docs
          .map((doc) => doc.get('_id') as String)
          .toSet()
          .toList();
      final groupIds = accountSnapshot.docs
          .map((doc) => doc.get('_groupID') as String)
          .toSet()
          .toList();

      // Thực hiện các truy vấn song song
      final futures = await Future.wait([
        _getStudentMistakes(accountIds),
        _getGroups(groupIds),
        _getStudentDetails(accountIds),
      ]);

      final studentMistakesMap = futures[0] as Map<String, StudentMistakeModel>;
      final groupsMap = futures[1] as Map<String, GroupModel>;
      final studentDetailsMap = futures[2] as Map<String, StudentDetailModel>;

      // Lấy classIDs từ StudentMistakeModel
      final classIDs = studentDetailsMap.values
          .map((stud) => stud.classID)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      print('class id$classIDs');
      // Lấy ClassMistakeModel tương ứng
      final classMistakesMap = await _getClassMistakes(classIDs);

      // Tạo danh sách kết quả
      return accountSnapshot.docs.map((accountDoc) {
        final account = AccountModel.fromFirestore(accountDoc);
        final studentMistake = studentMistakesMap[account.idAcc];
        return AccountEditModel(
          accountModel: account,
          studentMistakeModel: studentMistake,
          groupModel: groupsMap[account.goupID],
          studentDetailModel: studentDetailsMap[account.idAcc],
          classMistakeModel: studentMistake != null
              ? classMistakesMap[studentDetailsMap[account.idAcc]!.classID]
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<List<AccountEditModel>> fetchAccountsEditByGroup2(
      String idGroup) async {
    try {
      final accountSnapshot = await firestore
          .collection('ACCOUNT')
          .where('_groupID', isEqualTo: idGroup)
          .get();

      if (accountSnapshot.docs.isEmpty) return [];

      final accountIds = accountSnapshot.docs
          .map((doc) => doc.get('_id') as String)
          .toSet()
          .toList();
      final groupIds = accountSnapshot.docs
          .map((doc) => doc.get('_groupID') as String)
          .toSet()
          .toList();

      final futures = await Future.wait([
        _getTeacher(accountIds),
        _getGroups(groupIds),
      ]);

      final teacherMap = futures[0] as Map<String, TeacherModel>;
      final groupsMap = futures[1] as Map<String, GroupModel>;

      // Lọc các teacherID hợp lệ và không trùng lặp
      final teachIDs = teacherMap.values
          .where((teacher) => teacher.id.isNotEmpty)
          .map((teacher) => teacher.id)
          .toSet()
          .toList();

      final classMap = await _getClass(teachIDs);

      return accountSnapshot.docs.map((accountDoc) {
        final account = AccountModel.fromFirestore(accountDoc);
        final teach = teacherMap[account.idAcc];
        return AccountEditModel(
          accountModel: account,
          teacherModel: teach,
          groupModel: groupsMap[account.goupID],
          classMistakeModel: teach != null ? classMap[teach.id] : null,
        );
      }).toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<Map<String, ClassMistakeModel>> _getClass(
      List<String> teachIDs) async {
    if (teachIDs.isEmpty) return {};

    final snapshot = await firestore
        .collection('CLASS')
        .where('T_id', whereIn: teachIDs)
        .get();

    // Sửa lại key của map thành giá trị của trường 'T_id'
    return {
      for (var doc in snapshot.docs)
        (doc.data())['T_id'] as String: ClassMistakeModel.fromFirestore(doc),
    };
  }

  Future<Map<String, ClassMistakeModel>> _getClassMistakes(
      List<String> classIds) async {
    if (classIds.isEmpty) return {};
    final snapshot = await firestore
        .collection('CLASS')
        .where('_id', whereIn: classIds)
        .get();

    return {
      for (var doc in snapshot.docs)
        doc.id: ClassMistakeModel.fromFirestore(doc),
    };
  }

// Helper function để lấy StudentMistakes
  Future<Map<String, StudentMistakeModel>> _getStudentMistakes(
      List<String> accountIds) async {
    final snapshot = await firestore
        .collection('STUDENT')
        .where('ACC_id', whereIn: accountIds)
        .get();

    return {
      for (var doc in snapshot.docs)
        (doc.data()['ACC_id'] as String): StudentMistakeModel.fromFirestore(doc)
    };
  }

// Helper function để lấy gv
  Future<Map<String, TeacherModel>> _getTeacher(List<String> accountIds) async {
    final snapshot = await firestore
        .collection('TEACHER')
        .where('ACC_id', whereIn: accountIds)
        .get();

    return {
      for (var doc in snapshot.docs)
        (doc.data()['ACC_id'] as String): TeacherModel.fromFirestore(doc)
    };
  }

  // Helper function để lấy parent
  Future<Map<String, ParentModel>> _getParent(List<String> accountIds) async {
    final snapshot = await firestore
        .collection('PARENT')
        .where('ACC_id', whereIn: accountIds)
        .get();

    return {
      for (var doc in snapshot.docs)
        (doc.data()['ACC_id'] as String): ParentModel.fromFirestore(doc)
    };
  }

// Helper function để lấy Groups
  Future<Map<String, GroupModel>> _getGroups(List<String> groupIds) async {
    final snapshot = await firestore
        .collection('GROUP')
        .where('_id', whereIn: groupIds)
        .get();

    return {
      for (var doc in snapshot.docs)
        (doc.data()['_id'] as String): GroupModel.fromFirestore(doc)
    };
  }

// Helper function để lấy StudentDetails
  Future<Map<String, StudentDetailModel>> _getStudentDetails(
      List<String> accountIds) async {
    final studentMistakes = await _getStudentMistakes(accountIds);
    final studentIds = studentMistakes.values.map((e) => e.idStudent).toList();

    if (studentIds.isEmpty) return {};

    final snapshot = await firestore
        .collection('STUDENT_DETAIL')
        .where('ST_id', whereIn: studentIds)
        .get();

    final details = await Future.wait(
      snapshot.docs.map(
          (doc) async => StudentDetailModel.fromFirestore(doc, 'currentMonth')),
    );

    return {
      for (var detail in details)
        studentMistakes.entries
            .firstWhere((entry) => entry.value.idStudent == detail.idStudent)
            .key: detail
    };
  }
}


  // Future<List<AccountEditModel>> fetchAccountsEditByGroup(
  //     String idGroup) async {
  //   // Bước 1: Lấy danh sách tài khoản
  //   QuerySnapshot<Map<String, dynamic>> accountSnapshot = await firestore
  //       .collection('ACCOUNT')
  //       .where('_groupID', isEqualTo: idGroup) // Lọc theo groupID
  //       .get();

  //   List<AccountEditModel> accountEditList = [];

  //   // Bước 2: Lặp qua từng tài khoản để lấy thông tin liên quan
  //   for (var accountDoc in accountSnapshot.docs) {
  //     AccountModel accountModel = AccountModel.fromFirestore(accountDoc);

  //     // In ra thông tin tài khoản
  //     print('Account: ${accountModel.toString()}');

  //     // Bước 3: Lấy StudentMistakeModel bằng cách sử dụng account.idAcc
  //     QuerySnapshot<Map<String, dynamic>> studentMistakeSnapshot =
  //         await firestore
  //             .collection('STUDENT')
  //             .where('ACC_id', isEqualTo: accountModel.idAcc)
  //             .get();

  //     StudentMistakeModel? studentMistakeModel;

  //     if (studentMistakeSnapshot.docs.isNotEmpty) {
  //       studentMistakeModel = StudentMistakeModel.fromFirestore(
  //           studentMistakeSnapshot.docs.first);
  //       // In ra thông tin StudentMistakeModel
  //       print('StudentMistake: ${studentMistakeModel.toString()}');
  //     }

  //     //buoc 3+ lay ra groupmodel
  //     QuerySnapshot<Map<String, dynamic>> groupSnap = await firestore
  //         .collection('GROUP')
  //         .where('_id', isEqualTo: accountModel.goupID)
  //         .get();

  //     GroupModel? groupModel;

  //     if (groupSnap.docs.isNotEmpty) {
  //       groupModel = GroupModel.fromFirestore(groupSnap.docs.first);
  //       print('Group: ${groupModel.toString()}');
  //     }

  //     // Bước 4: Lấy StudentDetailModel nếu có
  //     StudentDetailModel? studentDetailModel;

  //     if (studentMistakeModel != null) {
  //       QuerySnapshot<Map<String, dynamic>> studentDetailSnapshot =
  //           await firestore
  //               .collection('STUDENT_DETAIL')
  //               .where('ST_id', isEqualTo: studentMistakeModel.idStudent)
  //               .limit(1)
  //               .get();

  //       if (studentDetailSnapshot.docs.isNotEmpty) {
  //         studentDetailModel = await StudentDetailModel.fromFirestore(
  //             studentDetailSnapshot.docs.first, 'currentMonth');
  //         // In ra thông tin StudentDetailModel
  //         print('StudentDetail: ${studentDetailModel.toString()}');
  //       }
  //     }

  //     // Bước 5: Tạo AccountEditModel và thêm vào danh sách
  //     AccountEditModel accountEditModel = AccountEditModel(
  //       accountModel: accountModel,
  //       studentDetailModel: studentDetailModel,
  //       studentMistakeModel: studentMistakeModel,
  //       groupModel: groupModel,
  //     );

  //     // In ra thông tin AccountEditModel
  //     print('AccountEditModel: ${accountEditModel.toString()}');

  //     accountEditList.add(accountEditModel);
  //   }

  //   return accountEditList; // Trả về danh sách AccountEditModel
  // }