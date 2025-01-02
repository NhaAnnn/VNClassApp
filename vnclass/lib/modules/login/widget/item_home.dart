import 'package:flutter/material.dart';

class ItemHome extends StatelessWidget {
  const ItemHome(
      {super.key, required this.icon, required this.title, this.onTap});
  final String icon;
  final String title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //width: 300,
        height: 150,
        decoration: BoxDecoration(
            color: const Color.fromARGB(
                251, 254, 254, 254), // Container cha màu đỏ
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30), // Màu bóng
                spreadRadius: 4, // Độ lan tỏa của bóng
                blurRadius: 7, // Độ mờ của bóng
                offset: Offset(0, 3),
              )
            ] // Bo tròn góc của Container cha
            ),
        child: Row(
          children: [
            // Container con màu xanh
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10)), // Bo tròn bên trái
                child: Container(
                  // width: 150, // Chiều rộng của Container con
                  height: 150, // Chiều cao của Container con
                  color: Colors.blue,
                  // width: 150, // Chiều rộng của Container con
                  // height: 150, // Chiều cao của Container con
                  child: Image.asset(
                    icon,
                  ),
                ),
              ),
            ),
            // Container con màu trắng
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(10)), // Bo tròn bên phải
                child: Container(
                  alignment: Alignment.centerLeft,
                  //width: 150, // Chiều rộng của Container con
                  height: 150,
                  color: const Color.fromARGB(
                      251, 254, 254, 254), // Chiều cao của Container con
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 8, 81, 140),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // child: Container(
      //   padding: EdgeInsets.all(
      //     12,
      //   ),
      //   decoration: BoxDecoration(
      //     color: Colors.blue,
      //     borderRadius: BorderRadius.all(
      //       Radius.circular(
      //         4,
      //       ),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: const Color.fromARGB(255, 149, 149, 149)
      //             .withAlpha(24), // Màu bóng
      //         spreadRadius: 5, // Độ lan tỏa
      //         blurRadius: 7, // Độ mờ
      //         offset: Offset(20, 30), // Vị trí bóng (x, y)
      //       ),
      //     ],
      //   ),
      //   child: SizedBox(
      //     height: 140,
      //     child: Row(
      //       children: [
      //         Expanded(
      //           flex: 3,
      //           child: SizedBox(
      //             height: 130,
      //             child: Container(
      //               height: 130,
      //               color: Colors.blue,
      //               child: Image.asset(
      //                 icon,
      //                 width: 120,
      //                 height: 120,
      //               ),
      //             ),
      //           ),
      //         ),
      //         Container(
      //           color: const Color.fromARGB(219, 255, 255, 255),
      //           child: SizedBox(
      //             width: 20,
      //             height: 130,
      //           ),
      //         ),
      //         Expanded(
      //           flex: 7,
      //           child: Container(
      //             color: const Color.fromARGB(179, 86, 5, 5),
      //             child: SizedBox(
      //               height: 140,
      //               child: Center(
      //                 child: Text(
      //                   title,
      //                   style: TextStyle(
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 28,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
