import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';

class ClassController {
  static Future<List<ClassModel>> fetchAllClasses() async {
    try {
      final QuerySnapshot =
          await FirebaseFirestore.instance.collection('CLASS').get();

      List<ClassModel> classes = []; // Khởi tạo danh sách học sinh

      for (var doc in QuerySnapshot.docs) {
        // Lặp qua từng tài liệu
        ClassModel classInfo = await ClassModel.fetchCLassFromFirestore(
            doc); // Gọi hàm lấy thông tin học sinh
        classes.add(classInfo); // Thêm học sinh vào danh sách
      }

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch mistake types: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }
}
