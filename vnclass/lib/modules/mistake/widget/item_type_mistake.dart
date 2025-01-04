import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';

class ItemTypeMistake extends StatelessWidget {
  const ItemTypeMistake({super.key});

  Future<List<TypeMistakeModel>> _fetchItems() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      return TypeMistakeModel.fromFirestore(doc); // Sử dụng từ factory
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TypeMistakeModel>>(
      future: _fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data!;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];

            return Container(
              margin: EdgeInsets.symmetric(
                  vertical: 4), // Khoảng cách giữa các item
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Border quanh item
                borderRadius: BorderRadius.circular(8), // Bo tròn góc
              ),
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8.0), // Khoảng cách giữa title và border
                  child: Text(item.idType),
                ),
                children: item.nameType // Sử dụng nameType làm children
                    .map(
                      (subtitle) => ListTile(
                        onTap: () => Navigator.of(context)
                            .pushNamed(MistakeWriteMistakePage.routeName),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subtitle),
                            Icon(FontAwesomeIcons.pen), // Thay đổi icon nếu cần
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }
}
