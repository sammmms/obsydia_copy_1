import 'dart:async';

import 'package:flutter/material.dart';

class JentionEditingController extends TextEditingController {
  Function(String? mention)? onMentionStateChanged;
  final List<Map<String, dynamic>> mentionList;

  JentionEditingController(
      {this.onMentionStateChanged, required this.mentionList}) {
    addListener(handleMentionDetect);
  }

  @override
  void dispose() {
    removeListener(handleMentionDetect);
    super.dispose();
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return TextSpan(text: text, style: TextStyle(color: Colors.black));
  }

  int? start;
  int? end;

  void handleMentionDetect() {
    int currentCursorPosition = value.selection.start;
    if (currentCursorPosition <= 0) {
      _setMentionInfo(null);
      return;
    }

    final preceedingText = text.substring(0, currentCursorPosition);
    final nearestPreceedingWhitespace =
        preceedingText.lastIndexOf(RegExp(r'\s'));
    final nearestPreceedingMention =
        preceedingText.lastIndexOf(RegExp(r'(\s\@|^\@)'));

    if (nearestPreceedingMention == -1) {
      _setMentionInfo(null);
      return;
    }
    if (nearestPreceedingWhitespace > nearestPreceedingMention) {
      _setMentionInfo(null);
      return;
    }

    int theStart = nearestPreceedingWhitespace + 2;

    final theText = text
        .substring(theStart, currentCursorPosition)
        .replaceFirst(RegExp(r'^\s'), "");

    _setMentionInfo(theStart, theText);
  }

  /// needed by handleMentionDetect
  void _setMentionInfo(int? index, [String? text]) {
    start = index;
    if (onMentionStateChanged != null) {
      onMentionStateChanged!(text);
    }
  }

  void applyMention(Map<String, dynamic> map) {
    if (start == null) {
      throw Exception('tidak sedang melakukan mentioning, gak bisa apply');
    }
    text = text.replaceRange(start! - 1, value.selection.start,
        '[@${map['name']}](user/${map['id']}) ');
    print(text);
  }
}
