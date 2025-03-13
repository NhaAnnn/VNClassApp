import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';

class UserChangeTypeMistakeScreenWeb extends StatefulWidget {
  const UserChangeTypeMistakeScreenWeb({super.key});
  static const String routeName = '/user_change_type_mistake_screen_web';

  @override
  State<UserChangeTypeMistakeScreenWeb> createState() =>
      _UserChangeTypeMistakeScreenWebState();
}

class _UserChangeTypeMistakeScreenWebState
    extends State<UserChangeTypeMistakeScreenWeb> {
  final MistakeController controller = MistakeController();
  final GlobalKey<ItemTypeMistakeState> itemTypeMistakeKey =
      GlobalKey<ItemTypeMistakeState>();

  // Hàm làm mới dữ liệu
  void _refreshData() async {
    await itemTypeMistakeKey.currentState?.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thiết lập vi phạm và loại vi phạm',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A))),
        leading: IconButton(
          icon: Icon(Icons.tune, size: 28, color: const Color(0xFF1E3A8A)),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hiển thị 2 nút riêng biệt với giao diện mới
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.plus, size: 16),
                    label: const Text('Thêm loại vi phạm'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => UserDialogAddType(
                          onUpdate: _refreshData,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.plus, size: 16),
                    label: const Text('Thêm vi phạm'),
                    onPressed: () {
                      controller.fetchMistakeTypes().then((items) {
                        showDialog(
                          context: context,
                          builder: (context) => UserDialogAddMistake(
                            showBtnDelete: false,
                            typeItems: items,
                            onUpdate: _refreshData,
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Hiển thị danh sách các loại và vi phạm
            ItemTypeMistake(
              key: itemTypeMistakeKey,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class UserDialogAddType extends StatefulWidget {
  final VoidCallback? onUpdate;
  const UserDialogAddType({super.key, this.onUpdate});

  @override
  _UserDialogAddTypeState createState() => _UserDialogAddTypeState();
}

class _UserDialogAddTypeState extends State<UserDialogAddType> {
  final TextEditingController _nameTypeController = TextEditingController();

  Future<void> _addTypeMistake() async {
    String nameMistakeType = _nameTypeController.text.trim();
    if (nameMistakeType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên loại vi phạm')));
      return;
    }
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('MISTAKE_TYPE').get();
    int docCount = snapshot.docs.length;
    String newId = 'MT0${docCount + 1}';
    await FirebaseFirestore.instance.collection('MISTAKE_TYPE').doc(newId).set({
      '_id': newId,
      '_mistakeTypeName': nameMistakeType,
      '_status': true,
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Thành công')));
    widget.onUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Thêm Loại Vi Phạm',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextfieldWidget(
              labelText: 'Tên loại vi phạm',
              controller: _nameTypeController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Thêm',
                    ontap: _addTypeMistake,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonWidget(
                    title: 'Hủy',
                    color: Colors.red,
                    ontap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Dialog: Thêm Vi Phạm
class UserDialogAddMistake extends StatefulWidget {
  final bool showBtnDelete;
  final bool mistakeDialog;
  final MistakeModel? mistake;
  final List<TypeMistakeModel>? typeItems;
  final VoidCallback? onUpdate;
  const UserDialogAddMistake({
    super.key,
    this.showBtnDelete = true,
    this.mistakeDialog = false,
    this.mistake,
    this.typeItems,
    this.onUpdate,
  });

  @override
  State<UserDialogAddMistake> createState() => _UserDialogAddMistakeState();
}

class _UserDialogAddMistakeState extends State<UserDialogAddMistake> {
  String? selectedOption;
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPoint = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.typeItems != null && widget.typeItems!.isNotEmpty) {
      selectedOption = widget.typeItems!.first.nameType;
    }
  }

  Future<void> _addTypeMistake() async {
    String nameMistake = _controllerName.text.trim();
    int? minusPoint = int.tryParse(_controllerPoint.text);
    final selectedType = widget.typeItems!.firstWhere(
      (type) => type.nameType == selectedOption,
      orElse: () => TypeMistakeModel(idType: '', nameType: '', status: true),
    );
    if (nameMistake.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên vi phạm')));
      return;
    }
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('MISTAKE').get();
    int docCount = snapshot.docs.length;
    String newId = 'M0${docCount + 1}';
    await FirebaseFirestore.instance.collection('MISTAKE').doc(newId).set({
      '_id': newId,
      'MT_id': selectedType.idType,
      '_mistakeName': nameMistake,
      '_minusPoint': minusPoint,
      '_status': true,
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Thành công')));
    widget.onUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Thêm Vi Phạm',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            DropMenuWidget(
              items:
                  widget.typeItems?.map((type) => type.nameType).toList() ?? [],
              selectedItem: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextfieldWidget(
              labelText: 'Nhập vi phạm',
              controller: _controllerName,
            ),
            const SizedBox(height: 16),
            TextfieldWidget(
              labelText: 'Điểm Trừ',
              controller: _controllerPoint,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Thêm',
                    ontap: _addTypeMistake,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonWidget(
                    title: 'Hủy',
                    color: Colors.red,
                    ontap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget: Hiển thị danh sách các loại và vi phạm
class ItemTypeMistake extends StatefulWidget {
  final MistakeController controller;
  const ItemTypeMistake({super.key, required this.controller});

  @override
  ItemTypeMistakeState createState() => ItemTypeMistakeState();
}

class ItemTypeMistakeState extends State<ItemTypeMistake> {
  List<TypeMistakeModel>? items;

  @override
  void initState() {
    super.initState();
    _loadMistakeTypes();
  }

  Future<void> _loadMistakeTypes() async {
    items = await widget.controller.fetchMistakeTypes();
    setState(() {});
  }

  Future<void> refreshData() async {
    await _loadMistakeTypes();
  }

  Future<void> _updateTypeMistake(
      TypeMistakeModel typeModel, bool status) async {
    final updatedMistake = TypeMistakeModel(
      idType: typeModel.idType,
      nameType: typeModel.nameType,
      status: status,
      mistakes: typeModel.mistakes,
    );
    try {
      await FirebaseFirestore.instance
          .collection('MISTAKE_TYPE')
          .doc(updatedMistake.idType)
          .update(updatedMistake.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
      await refreshData();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items!.length,
      itemBuilder: (context, index) {
        var item = items![index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ExpansionTile(
            leading: GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Xác nhận xóa'),
                  content: const Text(
                      'Bạn có chắc muốn xóa loại vi phạm này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        _updateTypeMistake(item, false);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            title: Text(item.nameType,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            children: item.mistakes!.map((mistake) {
              return ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => UserDialogEditType(
                      mistake: mistake,
                      typeItems: items,
                      onUpdate: () async => await refreshData(),
                    ),
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 8, child: Text(mistake.nameMistake)),
                    const Expanded(
                        flex: 2,
                        child: Icon(Icons.edit, color: Colors.blueGrey)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Dialog: Chỉnh Sửa Vi Phạm
class UserDialogEditType extends StatefulWidget {
  const UserDialogEditType({
    super.key,
    this.showBtnDelete = true,
    this.mistakeDialog = false,
    this.mistake,
    this.typeItems,
    this.onUpdate,
  });
  final bool showBtnDelete;
  final bool mistakeDialog;
  final MistakeModel? mistake;
  final List<TypeMistakeModel>? typeItems;
  final VoidCallback? onUpdate;

  @override
  State<UserDialogEditType> createState() => _UserDialogEditTypeState();
}

class _UserDialogEditTypeState extends State<UserDialogEditType> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPoint = TextEditingController();
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    _controllerName.text = widget.mistake?.nameMistake ?? '';
    _controllerPoint.text = widget.mistake?.minusPoint.toString() ?? '';
    if (widget.typeItems != null && widget.mistake != null) {
      final matchedType = widget.typeItems!.firstWhere(
        (type) => type.idType == widget.mistake!.mtID,
        orElse: () => TypeMistakeModel(
            idType: '', nameType: '', mistakes: [], status: false),
      );
      selectedOption =
          matchedType.nameType.isNotEmpty ? matchedType.nameType : null;
    }
  }

  Future<void> _updateMistake(bool status) async {
    if (widget.mistake == null || selectedOption == null) return;
    final selectedType = widget.typeItems!.firstWhere(
      (type) => type.nameType == selectedOption,
      orElse: () => TypeMistakeModel(idType: '', nameType: '', status: true),
    );
    final updatedMistake = MistakeModel(
      idMistake: widget.mistake!.idMistake,
      mtID: selectedType.idType,
      nameMistake: _controllerName.text,
      minusPoint: int.tryParse(_controllerPoint.text) ?? 0,
      status: status,
    );
    await FirebaseFirestore.instance
        .collection('MISTAKE')
        .doc(updatedMistake.idMistake)
        .update(updatedMistake.toMap());
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
    widget.onUpdate?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Chỉnh Sửa Vi Phạm',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropMenuWidget(
                items:
                    widget.typeItems?.map((type) => type.nameType).toList() ??
                        [],
                selectedItem: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextfieldWidget(
                labelText: 'Nhập vi phạm',
                controller: _controllerName,
              ),
              const SizedBox(height: 16),
              TextfieldWidget(
                labelText: 'Điểm Trừ',
                controller: _controllerPoint,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      title: 'Chỉnh sửa',
                      ontap: () async {
                        await _updateMistake(true);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ButtonWidget(
                      title: 'Hủy',
                      color: Colors.red,
                      ontap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.showBtnDelete)
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        title: 'Xóa Vi Phạm',
                        ontap: () async {
                          await _updateMistake(false);
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
