import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';

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

  JentionEditingController(
      {this.onMentionStateChanged}) {
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
    return TextSpan(text: text, style: const TextStyle(color: Colors.black));
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
      
      print("=========================================");
      print("=== textLength: ${value.text.length} => ${newValue.text.length}");
      print("=== selectStart: ${value.selection.start} => ${newValue.selection.start}");
      print("=== selectEnd: ${value.selection.end} => ${newValue.selection.end}");

      // preserve "preceeding mentions" + remove "intruded mentions" + adjust "traling mentions"
      var s = value.selection.start;
      var e = value.selection.end;
      var lAdjust = newValue.text.length - value.text.length; // length

      for (var i = mentions.length - 1; i >= 0; i--) {
        var mention = mentions[i];
        var shouldRemove = e >= mention.startIndex && s <= mention.endIndex;
        if (shouldRemove) {
          mentions.removeAt(i);
          printDatabase();
          continue;
        } 

        var shouldAdjust = mention.startIndex > s;
        if (shouldAdjust) {
          mention.startIndex = mention.startIndex + lAdjust;
          mention.endIndex = mention.endIndex + lAdjust;
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

    var newText = text.replaceRange(from, to, "@$name");
    var selectionIndex = from + name.length + 1;
    value = TextEditingValue(text: newText, selection: TextSelection.fromPosition(TextPosition(offset: selectionIndex)));

    mentions.add(MentionedItem(name, id, from, from + name.length));

    printDatabase();
  }

  // TODO: buang saat production nanti
  void printDatabase () {
    print('==== Database');
    for (var mention in mentions) {
      print(mention.toString());
    }
  }
}
