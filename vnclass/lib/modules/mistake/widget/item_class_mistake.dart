import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_class_detail_page.dart';

class ItemClassModels extends StatelessWidget {
  const ItemClassModels({
    super.key,
    required this.classMistakeModel,
    this.hocKy = '1',
    this.onRefresh, // Thêm callback
  });

  final ClassMistakeModel classMistakeModel;
  final String? hocKy;
  final Future<void> Function()? onRefresh; // Callback để làm mới dữ liệu

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          MistakeClassDetailPage.routeName,
          arguments: {
            'classMistakeModel': classMistakeModel,
            'hocKy': hocKy,
          },
        );
        if (onRefresh != null && context.mounted) {
          await onRefresh!(); // Gọi callback khi quay lại
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF1976D2),
            width: 0.8,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClassRow('Lớp:', classMistakeModel.className),
                    const SizedBox(height: 8),
                    _buildClassRow(
                        'Niên khóa:', classMistakeModel.academicYear),
                    const SizedBox(height: 8),
                    _buildClassRow('Sĩ số:', '${classMistakeModel.classSize}'),
                    const SizedBox(height: 8),
                    _buildClassRow('GVCN:', classMistakeModel.homeroomTeacher),
                    const SizedBox(height: 8),
                    _buildClassRow('Học kỳ:', hocKy ?? '1'),
                    const SizedBox(height: 8),
                    _buildClassRow('Số vi phạm:', _getNumberOfErrors(hocKy)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                FontAwesomeIcons.chevronRight,
                size: 24,
                color: Colors.black,
              ),
            ],
          ),
        ),
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
        return classMistakeModel.numberOfErrorS1;
    }
  }

  Widget _buildClassRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
