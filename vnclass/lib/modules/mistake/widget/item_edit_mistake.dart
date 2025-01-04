import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';

class ItemEditMistake extends StatelessWidget {
  const ItemEditMistake({super.key});

  Future<List<EditMistakeModel>> _fetchItems() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return EditMistakeModel(
        nameMistake: data['name'] ?? 'No Title',
        nameWriter: data['semester'] ?? 'No Writer',
        time: data['academicYear'] ?? 'No Time',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EditMistakeModel>>(
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
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    item.nameMistake,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                children: [
                  ListTile(
                    title: Text('Writer: ${item.nameWriter}'),
                  ),
                  ListTile(
                    title: Text('Time: ${item.time}'),
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(MistakeWriteMistakePage.routeName),
                              child: ButtonWidget(title: 'Chỉnh sửa'),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.04,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                CustomDialogWidget.showDeleteConfirmationDialog(
                                    context);
                              },
                              child: ButtonWidget(
                                title: 'Xóa',
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
