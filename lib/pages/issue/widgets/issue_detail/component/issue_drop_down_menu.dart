import 'package:flutter/material.dart';

class IssueDropDownMenu extends StatefulWidget {
  final List<String> items;
  final String itemSelected;
  const IssueDropDownMenu({
    super.key,
    required this.items,
    required this.itemSelected,
  });

  @override
  State<IssueDropDownMenu> createState() => _IssueDropDownMenuState();
}

class _IssueDropDownMenuState extends State<IssueDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(131, 124, 160, 179),
          border: Border.all(color: Colors.blueGrey),
          borderRadius: BorderRadius.circular(10)),
      height: 30,
      width: 100,
      child: DropdownButtonHideUnderline(
          child: DropdownButton(
        iconDisabledColor: const Color.fromARGB(238, 139, 150, 89),
        borderRadius: BorderRadius.circular(10),
        padding: const EdgeInsets.only(left: 10),
        value: widget.itemSelected,
        style: const TextStyle(color: Color.fromARGB(238, 139, 150, 89)),
        items: widget.items.map((item) {
          return DropdownMenuItem(value: item.toLowerCase(), child: Text(item));
        }).toList(),
        onChanged: null,
      )),
    );
  }
}
