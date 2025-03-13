import 'package:flutter/material.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';

class ClassMistakeProvider with ChangeNotifier {
  ClassMistakeModel? _classMistakeModel;
  String? _hocKy;

  ClassMistakeModel? get classMistakeModel => _classMistakeModel;
  String? get hocKy => _hocKy;

  void setClassMistake(ClassMistakeModel classMistakeModel, String hocKy) {
    _classMistakeModel = classMistakeModel;
    _hocKy = hocKy;
    notifyListeners();
  }

  void clear() {
    _classMistakeModel = null;
    _hocKy = null;
    notifyListeners();
  }
}
