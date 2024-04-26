import 'package:flutter/material.dart';

class DialogStateWidget extends StatelessWidget {
  final Widget content;
  const DialogStateWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: content,
      ),
    );
  }
}
