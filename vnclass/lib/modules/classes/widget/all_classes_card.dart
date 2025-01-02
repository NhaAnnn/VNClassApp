import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_add.dart';

class AllClassesCard extends StatefulWidget {
  const AllClassesCard({super.key});

  @override
  State<AllClassesCard> createState() => _AllClassesCardState();
}

class _AllClassesCardState extends State<AllClassesCard> {
  bool _isVisible = false;
  bool _isRotated = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // First Row
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      'Lớp:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                Expanded(flex: 8, child: Text('Column 2')),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Second Row
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      'Sỉ số:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                Expanded(flex: 8, child: Text('Column')),
                GestureDetector(
                  child: Transform.rotate(
                    angle: _isRotated ? 3.14 : 0,
                    child: Icon(FontAwesomeIcons.arrowDown),
                  ),
                  onTap: () => {
                    setState(() {
                      _isRotated = !_isRotated;
                      _isVisible = !_isVisible;
                    }),
                  },
                ),
                // Expanded(
                //   child: ButtonAdd(
                //     size: Size(50, 50),
                //     icon: Icon(FontAwesomeIcons.arrowDown),
                //     color: Colors.white,
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Third Row
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      'GVCN:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                Expanded(
                  flex: 8,
                  child: Text(
                      'Column 2sdfbusdfdjsfklngjdfsngjidfgbdsdfbusdfdjsfklngjdfsngjidfgbdfghfghfgh'),
                ),
              ],
            ),

            if (_isVisible)
              Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.solidEye,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Xem',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.pencil,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Sửa',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.solidTrashCan,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Xóa',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
