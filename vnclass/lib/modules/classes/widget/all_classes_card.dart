import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/class_detail/view/class_detail.dart';
import 'package:vnclass/modules/classes/widget/delete_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/update_class_dialog.dart';

class AllClassesCard extends StatefulWidget {
  const AllClassesCard({
    super.key,
    required this.classModel,
    this.onUpdate, // Callback để load lại dữ liệu
    // required this.onDelete, // Callback để load lại dữ liệu
  });

  final ClassModel classModel;
  final VoidCallback? onUpdate;
  // final VoidCallback onDelete;

  @override
  State<AllClassesCard> createState() => _AllClassesCardState();
}

class _AllClassesCardState extends State<AllClassesCard> {
  bool _isVisible = false;
  bool _isRotated = false;

  ClassModel get classModel => widget.classModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildClassRow('Lớp:', classModel.className.toString()),
                  _buildClassRow('Niên khóa:', classModel.year.toString()),
                  _buildClassRow('Sỉ số:', classModel.amount.toString()),
                  _buildClassRow('GVCN:', classModel.teacherName.toString()),
                  if (_isVisible) _buildControlRow(),
                ],
              ),
            ),
            GestureDetector(
              child: Transform.rotate(
                angle: _isRotated ? 3.14 : 0,
                child: Icon(
                  FontAwesomeIcons.angleDown,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  _isRotated = !_isRotated;
                  _isVisible = !_isVisible;
                });
              },
            ),
          ],
        ),
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
              flex: 3,
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(value, style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControlRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: _buildControlButton(
                'Xem', FontAwesomeIcons.solidEye, Colors.black),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(ClassDetail.routeName, arguments: {
                'classID': classModel.id,
                'className': classModel.className,
              });
            },
          ),
          GestureDetector(
            child: _buildControlButton(
                'Sửa', FontAwesomeIcons.pencil, Colors.blueAccent),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return UpdateClassDialog(
                    classModel: classModel,
                    onUpdate: widget.onUpdate!, // Gọi callback load lại dữ liệu
                  );
                },
              );
            },
          ),
          GestureDetector(
            child: _buildControlButton(
                'Xóa', FontAwesomeIcons.solidTrashCan, Colors.redAccent),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DeleteClassDialog(
                    classId: classModel.id.toString(),
                    onDelete: widget.onUpdate!, // Gọi callback load lại dữ liệu
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
