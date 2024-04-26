import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  int currentPage;

  PageProvider({required this.currentPage});

  void changePage(int newPage) {
    currentPage = newPage;

    notifyListeners();
  }
}
