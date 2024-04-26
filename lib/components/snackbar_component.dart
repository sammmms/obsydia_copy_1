import 'package:flutter/material.dart';

void showSnackBarComponent(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 1300), content: Text(content)));
}
