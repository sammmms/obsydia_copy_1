import 'package:flutter/material.dart';

class IssueTextField extends StatelessWidget {
  final Widget icons;
  final String text;
  const IssueTextField({super.key, required this.icons, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 150,
      child: TextField(
        controller: TextEditingController(text: text),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          enabled: false,
          filled: true,
          fillColor: const Color.fromARGB(131, 124, 160, 179),
          prefixIcon: icons,
          contentPadding: const EdgeInsets.all(0),
        ),
        style: const TextStyle(
            color: Color.fromARGB(238, 139, 150, 89), fontSize: 14),
      ),
    );
  }
}
