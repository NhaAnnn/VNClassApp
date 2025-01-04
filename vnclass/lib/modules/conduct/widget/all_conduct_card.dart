import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/conduct/conduct_detail/view/conduct_detail.dart';

class AllConductCard extends StatefulWidget {
  const AllConductCard({super.key});

  @override
  State<AllConductCard> createState() => _AllConductCardState();
}

class _AllConductCardState extends State<AllConductCard> {
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
          children: [
            Expanded(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // First Row
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            'Lớp:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(flex: 7, child: Text('Column 2')),
                    ],
                  ),
                  SizedBox(height: 8), // Space between rows

                  // Second Row
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            'Sỉ số:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(flex: 7, child: Text('Column 2dgsfhgdgsfhg')),
                    ],
                  ),
                  SizedBox(height: 8), // Space between rows

                  // Third Row
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            'GVCN:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(flex: 7, child: Text('Column 2')),
                    ],
                  ),
                  SizedBox(height: 8), // Space between rows

                  // Fourth Row
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Hạnh kiểm:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(
                          child: Text(
                        'Tốt:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Expanded(child: Text('34')),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Khá:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(child: Text('4')),
                    ],
                  ),
                  SizedBox(height: 8), // Space between rows

                  // Fifth Row
                  Row(
                    children: [
                      Expanded(flex: 2, child: Text('')),
                      Expanded(
                          child: Text(
                        'Đạt:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Expanded(child: Text('34')),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Chưa đạt:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(child: Text('4')),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).pushNamed(ConductDetail.routeName),
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  FontAwesomeIcons.angleRight,
                  size: 36,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
