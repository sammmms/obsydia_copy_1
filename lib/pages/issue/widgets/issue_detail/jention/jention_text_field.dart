import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/jention/jention_controller.dart';

class JentionTextField extends StatefulWidget {
  const JentionTextField({super.key});

  @override
  State<JentionTextField> createState() => _JentionTextFieldState();
}

class _JentionTextFieldState extends State<JentionTextField> {
  late JentionEditingController controller;
  bool shouldShowPortal = false;
  final List<Map<String, dynamic>> mentionList = [
    {"id": "662c65a5075bd50ff4b7cffa", "name": "Billy"},
    {"id": "662c65ae1d9923c3b64f9e19", "name": "Jeffry"},
    {"id": "662c65b56d619f0c399fc427", "name": "Sam"},
    {"id": "662c65baab124b0108622278", "name": "Jerry"},
  ];
  late List<Map<String, dynamic>> mentionable;
  String searching = "";

  @override
  void initState() {
    super.initState();
    controller = JentionEditingController(
        mentionList: mentionList,
        onMentionStateChanged: (value) {
          setState(() {
            shouldShowPortal = value != null;
            searching = value?.toLowerCase() ?? '';
            mentionable = mentionList
                .where((element) =>
                    element['name'].toLowerCase().contains(searching))
                .toList();
            print(mentionable);
          });
        });
    mentionable = mentionList;
  }

  @override
  Widget build(BuildContext context) {
    return PortalEntry(
      childAnchor: Alignment.topCenter,
      portalAnchor: Alignment.bottomCenter,
      visible: shouldShowPortal,
      portal: Container(
        height: 300,
        margin: const EdgeInsets.all(20),
        color: Colors.white,
        child: ListView.separated(
            itemCount: mentionable.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  controller.applyMention(mentionable[index]);
                },
                child: ListTile(
                  title: Text(mentionable[index]['id']),
                  subtitle: Text(mentionable[index]['name']),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            }),
      ),
      child: TextField(
        maxLines: 3,
        controller: controller,
      ),
    );
  }
}
