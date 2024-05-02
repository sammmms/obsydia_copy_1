import 'package:flutter/material.dart';

class MentionedItem {
  String text;
  String id;
  int startIndex;
  int endIndex;

  MentionedItem(this.text, this.id, this.startIndex, this.endIndex);

  @override
  String toString() {
    return '<$text> [$id]: start at $startIndex, end at: $endIndex';
  }
}

class JentionEditingController extends TextEditingController {
  Function(String? mention)? onMentionStateChanged;
  List<MentionedItem> mentions = [];

  JentionEditingController({this.onMentionStateChanged}) {
    addListener(handleMentionDetect);
  }

  @override
  void dispose() {
    removeListener(handleMentionDetect);
    super.dispose();
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<InlineSpan> listOfTextSpan = [];

    // TODO: refactor and comment
    int cursor = 0;
    for (var i = 0; i < mentions.length; i++) {
      var mention = mentions[i];
      if (mention.startIndex != cursor) {
        // create a normal text span before this mention
        var normalText = text.substring(cursor, mention.startIndex);
        listOfTextSpan.add(normalSpan(normalText));
      }
      var mentionText =
          text.substring(mention.startIndex, mention.endIndex + 1);
      listOfTextSpan.add(mentionSpan(mentionText));
      cursor = mention.endIndex + 1;
    }
    // Readjust, there's no need of -1 since we want to add space if there are any
    // Readjust, to <= since if the cursor somehow is greater than the text.length, we don't want to add any
    // substring, since it DOES happen in some cases, for example adding a mention, and removing word by word
    // creates this error where the cursor is greater than the text.length
    if (cursor <= text.length) {
      var normalText = text.substring(cursor, text.length);
      listOfTextSpan.add(normalSpan(normalText));
    }

    return TextSpan(
        children: listOfTextSpan, style: const TextStyle(color: Colors.black));
  }

  TextSpan normalSpan(String string) {
    return TextSpan(text: string, style: const TextStyle(color: Colors.black));
  }

  TextSpan mentionSpan(String string) {
    return TextSpan(text: string, style: const TextStyle(color: Colors.blue));
  }

  @override
  set value(TextEditingValue newValue) {
    // note:
    // method ini akan diinvoke saat:
    // - ada perubahan text
    // - ada perubahan seleksi
    //
    // pada kasus kita merubah seleksi (termasuk pindah kursor), secara internal method ini dipanggil sekali.
    //
    // namun saat kita mengedit text, method ini secara internal akan dipanggil dua kali, karena sebenarnya
    // terdapat dua kejadian: edit dan rubah seleksi
    //
    // pada kasus ini, kita hanya dengan saat terjadinya "perubahan", maka itu, logic kita dibungkus dengan if (old != new)
    //
    // sebenarnya terdapat juga kasus dimana kita melakukan seleksi sebagian text dan melakukan paste dengan nilai yang sama,
    // secara internal juga terjadi dua trigger, tetapi pada kasus kita, karena hasilnya menunjukkan nilai yang sama, maka kita
    // tidak bereaksi terhadap hasil yang sama.

    if (value.text != newValue.text) {
      // preserve "preceeding mentions" + remove "intruded mentions" + adjust "traling mentions"
      // Readjust variable name for easier readability
      var cursorStart = value.selection.start;
      var cursorEnd = value.selection.end;
      var lengthAdjust = newValue.text.length - value.text.length; // length

      for (var i = mentions.length - 1; i >= 0; i--) {
        var mention = mentions[i];
        var shouldRemove = cursorEnd > mention.startIndex &&
            cursorStart <= mention.endIndex + 1;
        // Only remove if the end cursor is greater than the startIndex, example.
        // cursorEnd = 6
        // text = abcde @Sam \\ @Sam.startIndex = 6
        // currently we're at |@
        // when we made any changes at cursorEnd = 6 (previous cursor), we won't really affect the mention
        // since pasting require the user to be at position 7, the same with deleting
        // adding things in cursorEnd = 6, only affect the mention position to be adjusted
        // ===================
        // Another one is with the cursorStart <= mention.endIndex, this here causes a problem where
        // If the cursor is on the endIndex, it doesn't remove the mention, example.
        // cursorStart = 4
        // text = @Sam
        // currently we're at @Sam|
        // removing any text after this should affect it, but since the logic before was cursorStart <= mention.endIndex
        // We're only removing the mention IF the cursorStart <= mention.endIndex, which are 4 <= 3
        // must remember, the cursorStart is the previous cursor position
        // We need to adjust this, so that if our previous cursor position was 4 and we delete anything it
        // would affect the condition so, we adjust the condition to cursorStart <= mention.endIndex + 1
        if (shouldRemove) {
          mentions.removeAt(i);
          printDatabase();
          continue;
        }

        var shouldAdjust = mention.startIndex >= cursorStart;
        if (shouldAdjust) {
          mention.startIndex = mention.startIndex + lengthAdjust;
          mention.endIndex = mention.endIndex + lengthAdjust;
          printDatabase();
        }
      }
    }

    super.value = newValue;
  }

  int? start;
  int? end;

  void handleMentionDetect() {
    int currentCursorPosition = value.selection.end;
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

    // Check if cursor position is inside a mention -Sam
    for (var mention in mentions) {
      if (currentCursorPosition >= mention.startIndex &&
          currentCursorPosition <= mention.endIndex + 1) {
        _setMentionInfo(null);
        return;
      }
    }

    int theStart = nearestPreceedingWhitespace + 1;

    final theText = text
        .substring(theStart + 1, currentCursorPosition)
        .replaceFirst(RegExp(r'^\s'), "");

    _setMentionInfo(theStart, theText);
  }

  /// needed by handleMentionDetect
  void _setMentionInfo(int? index, [String? text]) {
    start = index;
    if (onMentionStateChanged != null) {
      onMentionStateChanged!(text);
    }
  }

  void applyMention(String name, String id) {
    if (start == null) {
      throw Exception('tidak sedang melakukan mentioning, gak bisa apply');
    }

    int from = start!;
    int to = value.selection.end;
    var newText = text.replaceRange(from, to, "@$name ");
    var selectionIndex = from + name.length + 1;
    value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(
            TextPosition(offset: selectionIndex + 1)));

    var mentionedItem = MentionedItem(name, id, from, from + name.length);

    // tujuan kemudahan dan performance saat buildTextSpan()
    // kita perlu memastikan item-item mentions diurutan berdasarkan startIndex
    // dan juga untuk alasan performance, bagian add mention juga usahakan tidak melakukan
    // list.sort(), melainkan kita menambahkan secara manual, dari belakang, karena
    // pengetikan pesan cenderung terjadi di bagian belakang text.
    var insertionIndex = mentions.length;
    for (var i = mentions.length - 1; i >= 0; i--) {
      var itr = mentions[i];
      if (mentionedItem.startIndex <= itr.startIndex) {
        insertionIndex = i;
        break;
      }
    }
    mentions.insert(insertionIndex, mentionedItem);

    printDatabase();
  }

  // TODO: buang saat production nanti
  void printDatabase() {
    print('==== Database');
    for (var mention in mentions) {
      print(mention.toString());
    }
  }
}
