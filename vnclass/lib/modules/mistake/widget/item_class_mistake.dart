import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_class_detail_page.dart';

class ItemClassModels extends StatelessWidget {
  const ItemClassModels({
    super.key,
    required this.classMistakeModel,
    this.hocKy = '1',
  });

  final ClassMistakeModel classMistakeModel;
  final String? hocKy;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 1,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClassRow('Lớp:', classMistakeModel.className),
                  _buildClassRow('Niên khóa:', classMistakeModel.academicYear),
                  _buildClassRow('Sĩ số:', '${classMistakeModel.classSize}'),
                  _buildClassRow('GVCN:', classMistakeModel.homeroomTeacher),
                  _buildClassRow('Học kỳ:', hocKy ?? '1'), // In ra học kỳ
                  _buildClassRow('Số vi phạm:',
                      _getNumberOfErrors(hocKy)), // In ra số vi phạm
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              MistakeClassDetailPage.routeName,
              arguments: {
                'classMistakeModel': classMistakeModel,
                'hocKy': hocKy
              },
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                FontAwesomeIcons.arrowRight,
                size: 36,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNumberOfErrors(String? hocKy) {
    switch (hocKy) {
      case 'Học kỳ 1':
        return classMistakeModel.numberOfErrorS1;
      case 'Học kỳ 2':
        return classMistakeModel.numberOfErrorS2;
      case 'Cả năm':
        return classMistakeModel.numberOfErrorAll;
      default:
        return classMistakeModel.numberOfErrorS1; // Giá trị mặc định
    }
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
