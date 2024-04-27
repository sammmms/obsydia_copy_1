import 'dart:async';

import 'package:flutter/material.dart';

class MentionEditingController extends TextEditingController {
  final Function onSearchFunction;
  MentionEditingController({required this.onSearchFunction}) {
    addListener(detectMention);
    addListener(detectDelete);
  }

  // Declaration of consitantly updating value variable
  List<TextRange> mentionIndexRange = [];
  List<Map<String, dynamic>> mentionedPerson = [];
  int? start;
  int end = 0;
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
    RegExp patternToRecognizeMention = RegExp(r'@(\S){24}');
    List<Map<String, dynamic>> data = mentionedPerson;
    // context.read<MentionProvider>().mentioned ?? [];

    // Loop through every element in the listOfString (splitted string by whitespace)
    for (int index = 0; index < listOfString.length; index++) {
      //When the pattern matches the regex (every whitespace for 24 word)
      if (patternToRecognizeMention.hasMatch(listOfString[index])) {
        try {
          // Find the ID in the MAP, if it's not found, then return it as its self. (Usually doesn't happen very often)
          var foundedElement = data.firstWhere((dataElement) {
            return dataElement['id'] == listOfString[index].substring(1);
          });
          // Declare unicode to the string to match the length of the current controller.text (ID (26 length)) and the current display rendered (@{name})
          String unicode = '\u200b' *
              (foundedElement['id'].length - foundedElement['name'].length);
          //Append the @name together with the unicode
          listOfTextSpan.add(TextSpan(
              text: "@${foundedElement['name']}$unicode",
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold)));
          //If our mention is placed right in the end, there's no need to append an extra spaces, so we keep the loop continued
          //The code below works, so that we could render @sam @albert separated using spaces
          if (index == listOfString.length - 1) {
            continue;
          }
          listOfTextSpan.add(const TextSpan(text: ' '));
          needSpace = false;
        } catch (err) {
          listOfTextSpan.add(TextSpan(
              text: listOfString[index],
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              )));
        }
      } else {
        //This append spaces accordingly when user needs it ex. (samuel_), we append space, since the splitted string, results in empty list
        //After mention there are usually @name_ (spaces annotate as underline), which we don't want to append the space
        //Because we have already appended a spaces in line 47
        if (listOfString[index].isEmpty && needSpace) {
          listOfTextSpan.add(const TextSpan(
              text: " ",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              )));
          continue;
        } else {
          needSpace = true;
        }
        //Appending the string when it is not a mention
        listOfTextSpan.add(TextSpan(
            text: listOfString[index],
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
            )));
        //When we reach the end of the text, we don't need to append a whitespaces, and only append whitespaces by making use of the line 63 method,
        //which run when we are at the end of the spaces, and it indicates that the user DOES need it since the wrote " " by themselves
        if (index == listOfString.length - 1) {
          continue;
        }
        //This run to append string after each non-mentioned word ex. sam albert jeffrey
        listOfTextSpan.add(const TextSpan(
            text: " ",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
            )));
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

  ///This function is to be used on a controller, as a listener.
  ///Detects when user tries to delete a mention
  void detectDelete() {
    if (text.length < writtedText.length) {
      int currentCursorPosition = value.selection.baseOffset - 1;
      // Looping on every single mention user has created, saved as range (see line 195)
      for (var rangeIndex in mentionIndexRange) {
        // If the end met with the current cursor position, this mean that the user delete it on the last word (should delete every word in the mention)
        if (rangeIndex.end == currentCursorPosition) {
          mentionIndexRange.remove(rangeIndex);
          text = text.replaceRange(rangeIndex.start, rangeIndex.end + 1, "");
          break;
        }
        // If the end meet in the middle of the cursor position
        if (currentCursorPosition < rangeIndex.end &&
            currentCursorPosition >= rangeIndex.start) {
          mentionIndexRange.remove(rangeIndex);
          // INDEX
          String startToCurrentPositionString = writtedText.substring(0,
              currentCursorPosition); //This is just to get the substring of the first space (first divider of mention and word)
          //
          int mentionStartIndex =
              startToCurrentPositionString.lastIndexOf("@") != -1
                  ? startToCurrentPositionString.lastIndexOf("@")
                  : 0; //Find the start index of the mention
          //
          int mentionEndIndex = writtedText.indexOf(" ", mentionStartIndex) >
                  0 //Find the end index on the word before the text controller update
              ? writtedText.indexOf(" ", mentionStartIndex)
              : writtedText.length;
          //
          int replacedEndIndex = text.indexOf(" ",
              mentionStartIndex); //Find the end index of the current text controller text that need to be replaced
          //
          List<Map<String, dynamic>> data = mentionedPerson;
          String fullId =
              writtedText.substring(mentionStartIndex + 1, mentionEndIndex);
          String? nameOfIdHolder;
          //
          try {
            nameOfIdHolder =
                data.firstWhere((user) => user['id'] == fullId)['name'];
            int inSpanCursorPosition = currentCursorPosition -
                mentionStartIndex; //To find the index of the text that need to be discarded, ex. "Hello Billy" , delete i, we need to know the i index after the space, which are index = 1

            //If the cursor position somehow ended up further than the id holder name, then replace it to an empty string
            if (inSpanCursorPosition > nameOfIdHolder!.length) {
              text = text.replaceRange(
                  mentionStartIndex + 1, replacedEndIndex, "");
            } else {
              String newNameOfIdHolder = nameOfIdHolder.replaceRange(
                  inSpanCursorPosition, inSpanCursorPosition + 1, "");
              text = text.replaceRange(mentionStartIndex + 1,
                  replacedEndIndex + 1, newNameOfIdHolder);
              selection = TextSelection.fromPosition(
                  TextPosition(offset: currentCursorPosition + 1));
              start = mentionStartIndex;
              end = currentCursorPosition;
            }
          } catch (err) {
            text =
                text.replaceRange(mentionStartIndex + 1, replacedEndIndex, "");
          }
          break;
        }
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
