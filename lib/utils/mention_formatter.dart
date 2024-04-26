import 'package:flutter/material.dart';

class MentionFormatter {
  RegExp mentionPattern = RegExp(
      r'(?<=\[@)([^\]]+)(?=\])'); //Pattern to remove unnecessary letter in a mention
  RegExp patternToSplit =
      RegExp(r'(?<=\))\s+|\s+(?=\[)'); // Split into [string, mention, string]
  RegExp patternToReplace =
      RegExp(r'\[@[^\]]+\]\(.*?\)'); // Pattern to be able to recognize mention

  List<InlineSpan> mentionFormatter(String string) {
    List<String> splitResult = string.trimRight().split(patternToSplit);
    List<InlineSpan> regExResult = splitResult.map((element) {
      if (string == "") {
        return const TextSpan(text: '');
      }
      if (patternToReplace.hasMatch(element)) {
        return TextSpan(
            text: "@${mentionPattern.firstMatch(element)![0]!}",
            style: const TextStyle(
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w700,
                fontFamily: 'Quicksand'),
            children: const [
              WidgetSpan(
                  child: SizedBox(
                width: 5,
              ))
            ]);
      } else {
        return TextSpan(
            text: element,
            style: const TextStyle(
                color: Color.fromARGB(242, 21, 86, 139),
                fontWeight: FontWeight.w700,
                fontFamily: 'Quicksand'),
            children: const [
              WidgetSpan(
                  child: SizedBox(
                width: 5,
              ))
            ]);
      }
    }).toList();
    return regExResult;
  }

  RegExp patternToSplitMarkup = RegExp(
      r"(?=@\[__[^\]]*?__\]\(__[^\)]*?__\))|(?<=__\))\s+"); // Pattern to split string into [string, mention, string]
  RegExp patternForMarkupId =
      RegExp(r"@\[__([^\]]*)__\]"); //Pattern to recognize the ID
  RegExp patternForMarkupName =
      RegExp(r"\(__(.*?)__\)"); // Pattern to recognize markup name
  RegExp patternToKeepOnlyId = RegExp(
      r"[0-9a-zA-Z]+"); // Pattern to extract unnecessary stuff from the ID like braces and underscore
  RegExp patternToKeepOnlyName = RegExp(
      r"\(__([^\)]*)__\)"); // Pattern to extract unnecessary stuff from the name like braces and underscore
  RegExp patternToRecognize = RegExp(
      r"@\[__([^\]]*)__\]\(__(.*?)__\)"); // Pattern to recognize mention from string, used for replacing string.
  String commentMentionFormatter(String string) {
    List splittedString = string.split(patternToSplitMarkup);
    for (String substring in splittedString) {
      if (patternForMarkupId.hasMatch(substring)) {
        String markUpId = patternForMarkupId.firstMatch(substring)![0]!;
        String markUpName =
            patternForMarkupName.firstMatch(substring)?[0] ?? "";
        String id = patternToKeepOnlyId.firstMatch(markUpId)![0]!;
        String name = patternToKeepOnlyName.firstMatch(markUpName)![1]!;
        String mentionFormat = "[@$name](user/$id)";
        string = string.replaceFirst(patternToRecognize, mentionFormat);
      }
    }
    return string;
  }
}
