import 'package:flutter/material.dart';

class AllClassesCard extends StatefulWidget {
  const AllClassesCard({super.key});

  @override
  State<AllClassesCard> createState() => _AllClassesCardState();
}

class _AllClassesCardState extends State<AllClassesCard> {
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
                Expanded(flex: 2, child: Text('Lớp:')),
                Expanded(flex: 8, child: Text('Column 2')),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Second Row
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(flex: 2, child: Text('Sỉ số:')),
                Expanded(flex: 8, child: Text('Column 2dgsfhgdgsfhg')),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Third Row
            Row(
              children: [
                Expanded(flex: 2, child: Text('GVCN:')),
                Expanded(flex: 8, child: Text('Column 2')),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Fourth Row
            Row(
              children: [
                Expanded(flex: 2, child: Text('Hạnh kiểm:')),
                Expanded(child: Text('Tốt:')),
                Expanded(child: Text('34')),
                Expanded(child: Text('Khá:')),
                Expanded(child: Text('4')),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Fifth Row
            Row(
              children: [
                Expanded(flex: 2, child: Text('')),
                Expanded(child: Text('Trung bình:')),
                Expanded(child: Text('34')),
                Expanded(child: Text('Yếu:')),
                Expanded(child: Text('4')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
