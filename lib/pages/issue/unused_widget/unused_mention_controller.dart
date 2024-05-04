import 'dart:async';

import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/pages/issue/unused_widget/text_field_choice.dart';

class MentionEditingController extends TextEditingController {
  final Function onSearchFunction;
  MentionEditingController({required this.onSearchFunction}) {
    addListener(detectDelete);
    addListener(detectMention);
  }

  // Declaration of consitantly updating value variable
  List<TextRange> mentionIndexRange = [];
  List<Map<String, dynamic>> mentionedPerson = [];
  int? start;
  int currentEndPosition = 0;
  String writtedText = "";
  final isSuggestionVisible = StreamController<bool>();

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<InlineSpan> listOfTextSpan = [];
    List<String> listOfString = text.split(' ');
    bool needSpace = true;
    if (listOfString.length == 1 && listOfString[0] == "") {
      listOfString = [];
    }
    //Regular Expression Pattern to recognize @id (usually id is 24 length text consist of non-whitespace character)
    RegExp patternToRecognizeMention = RegExp(r'@(\S{24})');
    List<Map<String, dynamic>> data = mentionedPerson;
    // context.read<MentionProvider>().mentioned ?? [];

    // Loop through every element in the listOfString (splitted string by whitespace)
    for (int index = 0; index < listOfString.length; index++) {
      //When the pattern matches the regex (asdsad@asdasd)
      if (patternToRecognizeMention.hasMatch(listOfString[index])) {
        try {
          // Find the ID in the MAP, if it's not found, then return it as its self. (Usually doesn't happen very often)
          // Find the mention in a string of (sam@sam) -> (@sam)
          RegExpMatch? match =
              patternToRecognizeMention.firstMatch(listOfString[index]);
          String? mentionUser = match?[0];
          if (mentionUser == null) {
            throw "unfoundable";
          }
          // Find the index of the @
          int notMentionBoundary = listOfString[index].indexOf(mentionUser);
          // Get the string before the @, store it into a basic string
          String notMention =
              listOfString[index].substring(0, notMentionBoundary);
          listOfTextSpan.add(
            TextSpanChoice(content: notMention).normalTextSpan(),
          );

          var foundedElement = data.firstWhere((dataElement) {
            return dataElement['id'] == mentionUser.substring(1);
          });
          // Declare unicode to the string to match the length of the current controller.text (ID (26 length)) and the current display rendered (@{name})
          String unicode = '\u200b' *
              (foundedElement['id'].length - foundedElement['name'].length);

          //Append the @name together with the unicode
          listOfTextSpan.add(
            TextSpanChoice(content: "@${foundedElement['name']}$unicode")
                .mentionTextSpan(),
          );
          //If our mention is placed right in the end, there's no need to append an extra spaces, so we keep the loop continued
          //The code below works, so that we could render @sam @albert separated using spaces
          if (index == listOfString.length - 1) {
            continue;
          }
          listOfTextSpan.add(const TextSpan(text: ' '));
          needSpace = false;
        } catch (err) {
          listOfTextSpan.add(
            TextSpanChoice(content: listOfString[index]).normalTextSpan(),
          );
        }
      } else {
        //This append spaces accordingly when user needs it ex. (samuel_), we append space, since the splitted string, results in empty list
        //After mention there are usually @name_ (spaces annotate as underline), which we don't want to append the space
        //Because we have already appended a spaces in line 47
        if (listOfString[index].isEmpty && needSpace) {
          listOfTextSpan.add(
            TextSpanChoice(content: " ").normalTextSpan(),
          );
          continue;
        } else {
          needSpace = true;
        }
        //Appending the string when it is not a mention
        listOfTextSpan.add(
          TextSpanChoice(content: listOfString[index]).normalTextSpan(),
        );
        //When we reach the end of the text, we don't need to append a whitespaces, and only append whitespaces by making use of the line 63 method,
        //which run when we are at the end of the spaces, and it indicates that the user DOES need it since the wrote " " by themselves
        if (index == listOfString.length - 1) {
          continue;
        }
        //This run to append string after each non-mentioned word ex. sam albert jeffrey
        listOfTextSpan.add(
          TextSpanChoice(content: " ").normalTextSpan(),
        );
      }
    }
    return TextSpan(children: listOfTextSpan);
  }

  ///This function is a listener, need to be listened on a Controller
  ///It lisiten for a "@" and update the menu to show itself.
  void detectMention() {
    int currentCursorPosition = value.selection.start;
    if (currentCursorPosition <= 0) {
      _setMentionInfo(null);
      return;
    }
    currentEndPosition = value.selection.end;

    final preceedingText = text.substring(0, currentCursorPosition);
    final nearestPreceedingWhitespace =
        preceedingText.lastIndexOf(RegExp(r'\s'));
    final nearestPreceedingMention =
        preceedingText.lastIndexOf(RegExp(r'(\s\@|^\@)'));

    if (nearestPreceedingMention == -1) {
      _setMentionInfo(null);
      return;
    }
    if (nearestPreceedingWhitespace > nearestPreceedingMention) {
      _setMentionInfo(null);
      return;
    }

    int theStart = nearestPreceedingWhitespace + 1;

    final theText = text
        .substring(theStart, currentCursorPosition)
        .replaceFirst(RegExp(r'^\s'), "");

    _setMentionInfo(theStart, theText);
  }

  void detectDelete() {
    if (text.length < writtedText.length) {
      //Detects deletion, comparing text before update and after update.
      int currentCursorPosition = value.selection.start;
      if (currentCursorPosition <= 0) {
        writtedText = text;
        return;
      }
      if (RegExp(r'\s').hasMatch(writtedText[currentCursorPosition])) {
        writtedText = text;
        return;
      }
      final preceedingText = text.substring(0, currentCursorPosition);
      final nearestPreceedingWhitespace =
          preceedingText.lastIndexOf(RegExp(r'\s'));
      final nearestPreceedingMention =
          preceedingText.lastIndexOf(RegExp(r'(\s\@|^\@)'));

      if (nearestPreceedingMention == -1) {
        writtedText = text;
        return;
      }
      if (nearestPreceedingWhitespace > nearestPreceedingMention) {
        writtedText = text;
        return;
      }

      final theStart = nearestPreceedingWhitespace + 1;

      int nearestFollowingWhitespace =
          text.indexOf(RegExp(r'\s'), theStart + 1);
      if (nearestFollowingWhitespace == -1) {
        nearestFollowingWhitespace = text.length;
      }
      int nearestFollowingWhitespaceBeforeChange =
          writtedText.indexOf(RegExp(r'\s'), theStart + 1);
      if (nearestFollowingWhitespaceBeforeChange == -1) {
        nearestFollowingWhitespaceBeforeChange = text.length + 1;
      }
      // TODO : Now just need to recognize (MENTION and NOT MENTION and delete only MENTION)
      if (currentCursorPosition == nearestFollowingWhitespace) {
        if (text.substring(theStart, nearestFollowingWhitespace).length > 20) {
          text = text.replaceRange(theStart, nearestFollowingWhitespace, "");
        }
        writtedText = text;
        return;
      }
      final textBeforeChange = writtedText.substring(
          theStart, nearestFollowingWhitespaceBeforeChange);
      try {
        String nameFromId = mentionedPerson.firstWhere((element) =>
            element['id'] ==
            textBeforeChange.replaceFirst(RegExp(r'\s\@|^\@'), ""))['name'];
        int indexInPosition = currentCursorPosition - theStart - 1;
        int endIndexInPosition = currentEndPosition - theStart - 1;
        nameFromId =
            nameFromId.replaceRange(indexInPosition, endIndexInPosition, "");
        text = text.replaceRange(
            theStart, nearestFollowingWhitespace, "@$nameFromId");
        selection = TextSelection.fromPosition(
            TextPosition(offset: theStart + indexInPosition + 1));
      } catch (err) {
        // debugPrint(err.toString());
      }
    }
    writtedText = text;
  }

  void addMention(Map<String, dynamic> data) {
    start ??= 0;
    // Save a range of mention (start -> end)
    mentionIndexRange.add(TextRange(start: start!, end: start! + 23));
    //Replace text from start to current cursor position
    text = text.replaceRange(start!, value.selection.start, "@${data['id']} ");
    mentionedPerson.add(data);
  }

  void _setMentionInfo(int? index, [String? value]) {
    start = index;
    isSuggestionVisible.add(start != null);
    if (index != null) {
      onSearchFunction(value?.substring(
        1,
      ));
    }
  }
}
