import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedPage = 0;
  int get selectedPage => _selectedPage;

  void selectPage(int index) {
    _selectedPage = index;
    notifyListeners();
  }
}
