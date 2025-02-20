import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/model/conduct_month_model.dart';

class ConductMonthController {
  static Future<ConductMonthModel> fetchConductMonth(String studentID) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('CONDUCT_MONTH')
          .doc(studentID)
          .get(); // Lấy một lần tất cả tài liệu

      // Chuyển đổi các tài liệu thành danh sách ConductMonthModel

      if (snapshot.exists) {
        return ConductMonthModel.fromFirestore(snapshot);
      } else {
        return ConductMonthModel(); // Hoặc một giá trị mặc định nếu không tìm thấy
      }
    } catch (e) {
      print("Error fetching conduct month data: $e");
      return ConductMonthModel(); // Trả về danh sách rỗng nếu có lỗi
    }
  }

  static Future<ConductMonthModel> fetchAllConductMonthByOneMonth(
      String studentID, String monthKey) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('CONDUCT_MONTH')
          .doc(studentID)
          .get(); // Lấy tài liệu từ Firestore

      // Kiểm tra nếu tài liệu tồn tại
      if (!snapshot.exists) {
        print("Document does not exist");
        return ConductMonthModel(); // Trả về đối tượng rỗng nếu tài liệu không tồn tại
      }

      // Chuyển đổi dữ liệu từ snapshot
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      // Kiểm tra nếu dữ liệu cho monthKey tồn tại
      if (data != null /*&& data.containsKey(monthKey)*/) {
        var monthData = data['_month'][monthKey];
        return ConductMonthModel(
          studentID: studentID,
          months: {
            monthKey: [
              monthData[0] ?? '', // Hành kiểm
              monthData[1] ?? 0, // Điểm rèn luyện
            ]
          },
        );
      } else {
        print("No data found for the specified month key");
        return ConductMonthModel(); // Trả về đối tượng rỗng nếu không có dữ liệu
      }
    } catch (e) {
      print("Error fetching conduct month data: $e");
      return ConductMonthModel(); // Trả về đối tượng rỗng nếu có lỗi
    }
  }

  static Future<String> fetchConductMonthByOneMonth(
      String studentID, String monthKey, int n) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('CONDUCT_MONTH')
          .doc(studentID)
          .get();

      if (!snapshot.exists) {
        // print("Document does not exist");
        return '';
      }

      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null &&
          data['_month'] != null &&
          data['_month'].containsKey(monthKey)) {
        var monthData = data['_month'][monthKey];
        return monthData[n]?.toString() ?? '';
      } else {
        // print("No data found for the specified month key");
        return '';
      }
    } catch (e) {
      print("Error fetching conduct month data: $e");
      return '';
    }
  }
}
