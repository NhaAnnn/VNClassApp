import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/class_detail/view/class_detail.dart';
import 'package:vnclass/modules/classes/widget/delete_class_dialog.dart';
import 'package:vnclass/modules/classes/widget/update_class_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vnclass/modules/login/controller/provider.dart';

class AllClassesCard extends StatefulWidget {
  const AllClassesCard({
    super.key,
    required this.classModel,
    this.onUpdate,
    this.onSelect,
  });

  final ClassModel classModel;
  final VoidCallback? onUpdate;
  final Function(ClassModel)? onSelect;

  @override
  State<AllClassesCard> createState() => _AllClassesCardState();
}

class _AllClassesCardState extends State<AllClassesCard> {
  bool _isVisible = false;
  bool _isRotated = false;

  ClassModel get classModel => widget.classModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to class details directly when the card is clicked on web

        if (kIsWeb) {
          widget.onSelect!(classModel);
          _openRightDrawer(context);
        }
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blueAccent, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment:
                kIsWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildClassRow('Lớp:', classModel.className.toString()),
                    _buildClassRow('Niên khóa:', classModel.year.toString()),
                    _buildClassRow('Sỉ số:', classModel.amount.toString()),
                    _buildClassRow('GVCN:', classModel.teacherName.toString()),
                    if (!kIsWeb) ...[
                      if (_isVisible) _buildControlRow(),
                    ]
                  ],
                ),
              ),
              if (kIsWeb) ...[
                if (Provider.of<AccountProvider>(context, listen: false)
                        .account!
                        .goupID !=
                    'giaoVien') ...[
                  PopupMenuButton<String>(
                    icon: const Icon(FontAwesomeIcons.ellipsis, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return UpdateClassDialog(
                              classModel: classModel,
                              onUpdate: widget.onUpdate!,
                            );
                          },
                        );
                        widget.onUpdate!();
                      } else if (value == 'remove') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeleteClassDialog(
                              classId: classModel.id.toString(),
                              onDelete: widget.onUpdate!,
                            );
                          },
                        );
                        widget.onUpdate!();
                      }
                    },
                    itemBuilder: (context) => [
                      _customPopupMenuItem(
                          'edit',
                          'Chỉnh sửa',
                          TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w500),
                          Icon(FontAwesomeIcons.pencil,
                              color: Colors.blue, size: 20)),
                      _customPopupMenuItem(
                          'remove',
                          'Xóa',
                          TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                          Icon(FontAwesomeIcons.solidTrashCan,
                              color: Colors.red, size: 20)),
                    ],
                  ),
                ],
              ] else ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRotated = !_isRotated;
                      _isVisible = !_isVisible;
                    });
                  },
                  child: Transform.rotate(
                    angle: _isRotated ? 3.14 : 0,
                    child: Icon(
                      FontAwesomeIcons.angleDown,
                      size: 36,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openRightDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  PopupMenuEntry<String> _customPopupMenuItem(
      String value, String text, TextStyle textStyle, Icon icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 10),
            Text(
              text,
              style: textStyle,
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
                style: kIsWeb
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 27, 78, 121))
                    : TextStyle(fontWeight: FontWeight.bold),
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
              if (Provider.of<AccountProvider>(context, listen: false)
                      .account!
                      .goupID ==
                  'banGH') {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return UpdateClassDialog(
                      classModel: classModel,
                      onUpdate: widget.onUpdate!,
                    );
                  },
                );
              } else {
                // Show a message or do nothing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bạn không có quyền sửa lớp này.'),
                  ),
                );
              }
            },
          ),
          GestureDetector(
            child: _buildControlButton(
                'Xóa', FontAwesomeIcons.solidTrashCan, Colors.redAccent),
            onTap: () async {
              if (Provider.of<AccountProvider>(context, listen: false)
                      .account!
                      .goupID ==
                  'banGH') {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteClassDialog(
                      classId: classModel.id.toString(),
                      onDelete: widget.onUpdate!,
                    );
                  },
                );
              } else {
                // Show a message or do nothing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bạn không có quyền xóa lớp này.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
