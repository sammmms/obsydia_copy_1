import 'dart:async';

import 'package:flutter/material.dart';

class MentionedItem {
  String text;
  String id;
  int startIndex;
  int endIndex;

  MentionedItem(this.text, this.id, this.startIndex, this.endIndex);

  // A method to call to return mention into a back-end received formats
  @override
  String toString() {
    return '[@$text](user/$id)';
  }
}

class JentionEditingController extends TextEditingController {
  // What function to run right after a user enter a field of Mention
  Function(String? mention)? onMentionStateChanged;
  // A stream controller, to control the appear/disappear of mention suggestion list
  final isSuggestionVisible = StreamController<bool>();
  // List of all mentioned user inside a single text field
  List<MentionedItem> mentions = [];
  // On controller declaration, listen on handleMentionDetect, to show mention suggestion
  JentionEditingController({this.onMentionStateChanged}) {
    addListener(handleMentionDetect);
  }

  // Get the markup text, return a format where back-end receiver can acknowledge mentions.
  String getMarkupText() {
    String result = "";
    int cursor = 0;
    // Using the same method as building text span
    for (var mention in mentions) {
      if (mention.startIndex != cursor) {
        var normalText = text.substring(cursor, mention.startIndex);
        result += normalText;
      }

      result += mention.toString();
      cursor = mention.endIndex + 1;
    }

    if (cursor <= text.length) {
      var normalText = text.substring(cursor, text.length);
      result += normalText;
    }
    return result;
  }

  // A function to reset the field, also all mention character
  void resetField() {
    mentions = [];
    text = "";
  }

  // Disposing listener to avoid it from keep listening to the field
  @override
  void dispose() {
    removeListener(handleMentionDetect);
    super.dispose();
  }

  // Run right after the new value has been assigned by the set value function
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<InlineSpan> listOfTextSpan = [];

    // Setting the cursor to the start of field
    int currentIndex = 0;

    // Looping thorugh every mentioned user
    for (var i = 0; i < mentions.length; i++) {
      var mention = mentions[i];

      // Case : When the currentIndex is not the start of mention
      //        every text before the current mention, must be added as a normal text to the text span
      if (mention.startIndex != currentIndex) {
        var normalText = text.substring(currentIndex, mention.startIndex);
        listOfTextSpan.add(normalSpan(normalText));
      }

      // Add the current mention text to the text span
      var mentionText =
          text.substring(mention.startIndex, mention.endIndex + 1);
      listOfTextSpan.add(mentionSpan(mentionText));

      //Adjust the index to the end of the current mention
      currentIndex = mention.endIndex + 1;
    }

    // When the iteration has stopped, meaning we reach the last mention
    // Case : If there are any text left behind the current mention end
    //        every text right after the mention end, should be added as a normal text to the text span
    if (currentIndex <= text.length) {
      var normalText = text.substring(currentIndex, text.length);
      listOfTextSpan.add(normalSpan(normalText));
    }

    // When the process above has done, return all text span.
    return TextSpan(
        children: listOfTextSpan, style: const TextStyle(color: Colors.black));
  }

  // A normal text span
  TextSpan normalSpan(String string) {
    return TextSpan(
      text: string,
      style: const TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.black,
      ),
    );
  }

  // A mention text span
  TextSpan mentionSpan(String string) {
    return TextSpan(
      text: string,
      style: const TextStyle(
          fontFamily: 'Quicksand',
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold),
    );
  }

  // Run right after we edit a value, just before we build the new text span.
  @override
  set value(TextEditingValue newValue) {
    // Only run when there are difference in [selection position, and text]
    if (newValue != value) {
      // Declaration of needed variable
      var prevSelLength = value.selection.end - value.selection.start;
      var currentSelLength = newValue.selection.end - newValue.selection.start;
      var lengthAdjust = newValue.text.length - value.text.length;

      var isCertainlyAdjustingSelection = currentSelLength > 0;
      var isCertainlyMovingArround =
          lengthAdjust == 0 && currentSelLength == 0 && prevSelLength == 0;

      // Case : Only moving cursor or just moving selection around
      // Stop iterating through each mentions to save performance
      if (isCertainlyAdjustingSelection || isCertainlyMovingArround) {
        super.value = newValue;
        return;
      }

      // Check if any text is intruded under selection
      var intrusionStart = value.selection.start;
      var intrusionEnd = value.selection.end;

      // Case : There's no need of length adjust, meaning user has either replaced characters
      // Or cancelling selection
      if (lengthAdjust == 0) {
        // Comparing old selected text, to the new text, if there's no difference
        // Then stop iterating through each mention also to save performance
        var oldSelectedText =
            value.text.substring(value.selection.start, value.selection.end);
        var newChangedText =
            newValue.text.substring(value.selection.start, value.selection.end);

        // Case : The text are the same, there's no need to proceed through,
        // just need to return the new selection, in this case it's called newValue,
        // since newValue is TextEditingValue that contains selection inside.
        if (oldSelectedText == newChangedText) {
          super.value = newValue;
          return;
        }
      }

      // If length adjust is minus, meaning the user has delete a character
      // Previous select length is 0, meaning the user is not making selection
      if (lengthAdjust < 0 && prevSelLength == 0) {
        // Case : User delete a character using "backspace" button
        // When user cursor start moving backwards, meaning user had deleted a character using backspace
        if (value.selection.start != newValue.selection.start) {
          intrusionStart = newValue.selection.start;
        } else {
          // Case : User delete a character using "delete" button
          // When user cursor stays, user had removed a character using "delete" button
          intrusionEnd++;
        }
      }

      // Iterating through each mention
      for (var i = mentions.length - 1; i >= 0; i--) {
        var mention = mentions[i];

        // Flagging a mention should be removed if their previous selection was inside a mention.
        // Meaning they had intruded a mention
        var shouldRemove = intrusionEnd > mention.startIndex &&
            intrusionStart <= mention.endIndex;

        if (shouldRemove) {
          // Removing a mention from array, so that buildTextSpan don't need to render it as a "mention"
          mentions.removeAt(i);
          continue;
        }

        // Flagging a mention should be adjusted its startIndex and endIndex
        // Case : When a mention is behind the user cursor, and any changes happen,
        //        a mention should be adjusted its starts and ends position
        var shouldAdjust = mention.startIndex >= intrusionStart;
        if (shouldAdjust) {
          // Adjusting be the length, (-) if any character is removed, (+) if any character is added
          mention.startIndex = mention.startIndex + lengthAdjust;
          mention.endIndex = mention.endIndex + lengthAdjust;
        }
      }
    }

    // Apply the new updated value to the field
    super.value = newValue;
  }

  int? start;
  int? end;

  void handleMentionDetect() {
    // Starting out, the cursor position will be -1, and error will emerge, we need to stop proceeding
    int currentCursorPosition = value.selection.end;
    if (currentCursorPosition <= 0) {
      _setMentionInfo(null);
      return;
    }

    // Get all the text from start, until the current position
    final preceedingText = text.substring(0, currentCursorPosition);

    // Find the nearest whitespace to the cursor position
    final nearestPreceedingWhitespace =
        preceedingText.lastIndexOf(RegExp(r'\s'));

    // Find the nearest mention to the cursor position
    final nearestPreceedingMention =
        preceedingText.lastIndexOf(RegExp(r'(\s\@|^\@)'));

    // If no mention are found, or found whitespace are not beside the mention
    // There's no need to proceed, since its certain that we are not in the text

    if (nearestPreceedingMention == -1) {
      _setMentionInfo(null);
      return;
    }
    if (nearestPreceedingWhitespace > nearestPreceedingMention) {
      _setMentionInfo(null);
      return;
    }

    // Check if cursor position is inside a mention
    for (var mention in mentions) {
      if (nearestPreceedingWhitespace + 1 == mention.startIndex) {
        _setMentionInfo(null);
        return;
      }
    }

    // The start is from '@'
    int theStart = nearestPreceedingWhitespace + 1;

    // Obtaining the text after '@'
    final theText = text
        .substring(theStart + 1, currentCursorPosition)
        .replaceFirst(RegExp(r'^\s'), "");

    _setMentionInfo(theStart, theText);
  }

  // Setting the start index, null meaning there's no mention detected
  // Set suggestion showing, also running passed function.
  void _setMentionInfo(int? index, [String? text]) {
    start = index;
    if (start != null) {
      isSuggestionVisible.add(true);
    } else {
      isSuggestionVisible.add(false);
      return;
    }
    if (onMentionStateChanged != null) {
      onMentionStateChanged!(text);
    }
  }

  void applyMention(String name, String id) {
    // Just an exception that rarely fire, unless there are a bug where mention list is shown up
    // when it's not supposed to shows.
    if (start == null) {
      throw Exception("Not in mentioning state, can't apply mention.");
    }

    // Start is set by _setMentionInfo, and when user are mentioning, start are always set to the "@" position
    int from = start!;
    int to = value.selection.end;

    // The new text to replace the current text with
    var newText = text.replaceRange(from, to, "@$name ");
    var selectionIndex = from + name.length + 1;

    // New value to assert into the text field, using text editing value instead of assigning to
    // text variable, because cursor must also be move together with text.
    value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(
            TextPosition(offset: selectionIndex + 1)));

    // After applying mention to the field, mention must be save into a list, since there are many
    // information to be digest, it must be first created into a class
    var mentionedItem = MentionedItem(name, id, from, from + name.length);

    // Pushing the mention at the right position inside the list
    var insertionIndex = mentions.length;
    for (var i = mentions.length - 1; i >= 0; i--) {
      var currentIterated = mentions[i];
      // Case : When a mention start index is smaller then the current start index
      //        meaning that the start index is supposed to be before the current mention
      if (mentionedItem.startIndex <= currentIterated.startIndex) {
        insertionIndex = i;
      } else {
        // Case : When the mention is no longer smaller than the current iterating mention
        //        meaning that its already in its supposed position, stop the loop
        break;
      }
    }

    // Insert the mention to the list at the right index
    mentions.insert(insertionIndex, mentionedItem);
  }
}
