import 'package:flutter/material.dart';

class PostFilterProvider extends ChangeNotifier {
  String _selectedFilter = 'All';

  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
