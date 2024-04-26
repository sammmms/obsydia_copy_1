import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';
import 'package:obsydia_copy_1/utils/activity_type_util.dart';

class DialogCardComponent extends StatelessWidget {
  final Activity content;
  const DialogCardComponent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 140, child: Text(content.text)),
              Chip(
                label: Text(ActivityTypeUtil().statusTextOf(content.type)),
              )
            ],
          )),
    );
  }
}
