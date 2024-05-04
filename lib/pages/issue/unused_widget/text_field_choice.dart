import 'package:flutter/material.dart';

class TextSpanChoice {
  final String content;

  TextSpanChoice({required this.content});

  InlineSpan normalTextSpan() {
    return TextSpan(
        text: content,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
        ));
  }

  InlineSpan mentionTextSpan() {
    return TextSpan(
        text: content,
        style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold));
  }
}
