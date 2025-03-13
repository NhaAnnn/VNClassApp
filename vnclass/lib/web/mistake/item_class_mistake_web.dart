import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/providers/class_mistake_provider.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';
import 'package:vnclass/web/mistake/mistake_class_detail_page_web.dart';

class ItemClassModelsWeb extends StatelessWidget {
  const ItemClassModelsWeb({
    super.key,
    required this.classMistakeModel,
    this.hocKy = 'Học kỳ 1',
    this.onRefresh,
  });

  final ClassMistakeModel classMistakeModel;
  final String? hocKy;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          Provider.of<ClassMistakeProvider>(context, listen: false)
              .setClassMistake(classMistakeModel, hocKy ?? 'Học kỳ 1');

          await Navigator.pushNamed(
            context,
            MistakeClassDetailPageWeb.routeName,
            arguments: {
              'classMistakeModel': classMistakeModel,
              'hocKy': hocKy,
            },
          );
          if (onRefresh != null && context.mounted) {
            await onRefresh!();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClassRow('Lớp:', classMistakeModel.className),
                        const SizedBox(height: 7),
                        _buildClassRow(
                            'Niên khóa:', classMistakeModel.academicYear),
                        const SizedBox(height: 7),
                        _buildClassRow(
                            'Sĩ số:', '${classMistakeModel.classSize}'),
                        const SizedBox(height: 7),
                        _buildClassRow(
                            'GVCN:', classMistakeModel.homeroomTeacher),
                        const SizedBox(height: 7),
                        _buildClassRow('Học kỳ:', hocKy ?? 'Học kỳ 1'),
                        const SizedBox(height: 7),
                        _buildClassRow(
                            'Số vi phạm:', _getNumberOfErrors(hocKy)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 18,
                    color: Color(0xFF1E3A8A),
                  ),
                ],
              ),
            ),
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
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
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
