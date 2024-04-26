import 'package:flutter/material.dart';

class CreateIssueDialog extends StatelessWidget {
  const CreateIssueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [OutlinedButton(onPressed: () {}, child: const Text("Submit"))],
      title: const Text("Add new issue"),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(),
            TextFormField(),
            TextFormField(),
          ],
        ),
      ),
    );
  }
}
