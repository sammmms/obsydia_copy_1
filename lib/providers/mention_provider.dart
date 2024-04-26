import 'package:flutter/material.dart';

class MentionProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? mentioned;
  List<Map<String, dynamic>>? mentionable;

  MentionProvider({this.mentionable, this.mentioned});

  void updateMentionable(List<Map<String, dynamic>> newMentionable) {
    mentionable = newMentionable;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void onLoadingMentionable() {
    mentionable = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void addMentioned(Map<String, dynamic> newMentioned) {
    if (mentioned == null) {
      mentioned = [newMentioned];
    } else {
      mentioned!.add(newMentioned);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void refreshMentioned() {
    mentioned = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
