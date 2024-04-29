import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/mention/mention_controller.dart';
import 'package:obsydia_copy_1/providers/mention_provider.dart';
import 'package:provider/provider.dart';

class MentionTextField extends StatefulWidget {
  final Function onSearchFunction;
  final MentionEditingController controller;
  final TextStyle? style;
  final Widget? suffix;
  const MentionTextField(
      {super.key,
      required this.onSearchFunction,
      required this.controller,
      this.style,
      this.suffix});

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  late MentionEditingController controller;

  @override
  void initState() {
    controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: controller.isSuggestionVisible.stream,
        initialData: false,
        builder: (context, snapshot) {
          return PortalEntry(
              portalAnchor: Alignment.bottomCenter,
              childAnchor: Alignment.topCenter,
              visible: snapshot.data!,
              portal: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: (context.watch<MentionProvider>().mentionable !=
                                  null) &&
                              (context
                                      .watch<MentionProvider>()
                                      .mentionable
                                      ?.isNotEmpty ??
                                  false)
                          ? Container(
                              constraints: const BoxConstraints(maxHeight: 300),
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(150, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey)),
                              width: double.infinity,
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        indent: 20,
                                        endIndent: 20,
                                      ),
                                  itemCount: context
                                          .watch<MentionProvider>()
                                          .mentionable
                                          ?.length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        context
                                            .read<MentionProvider>()
                                            .addMentioned(context
                                                .read<MentionProvider>()
                                                .mentionable![index]);
                                        controller.addMention(context
                                            .read<MentionProvider>()
                                            .mentionable![index]);
                                      },
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20),
                                        leading: const CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.grey,
                                          child: Icon(
                                            Icons.person,
                                            color: Color.fromARGB(
                                                255, 180, 180, 180),
                                          ),
                                        ),
                                        title: Text(
                                          context
                                              .read<MentionProvider>()
                                              .mentionable![index]['name'],
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        subtitle: Text(
                                          "@${context.read<MentionProvider>().mentionable![index]['username']}",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    );
                                  }))
                          : const SizedBox()),
                ),
              ),
              child: SizedBox(
                child: TextField(
                  maxLines: 3,
                  minLines: 1,
                  style: widget.style,
                  controller: controller,
                  decoration: InputDecoration(
                    suffixIcon: widget.suffix,
                  ),
                ),
              ));
        });
  }
}
