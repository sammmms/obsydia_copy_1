import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/comment/comment_state.dart';

class SendButton extends StatelessWidget {
  final CommentState state;
  final Function() handleSentComment;
  const SendButton(
      {super.key, required this.state, required this.handleSentComment});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return OutlinedButton(
        style: const ButtonStyle(
            shape: MaterialStatePropertyAll(
              CircleBorder(
                side: BorderSide(color: Colors.white),
              ),
            ),
            side:
                MaterialStatePropertyAll(BorderSide(color: Colors.transparent)),
            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
        onPressed: state.loading ? null : handleSentComment,
        child: state.loading
            ? const CircularProgressIndicator(
                color: Color.fromARGB(242, 21, 86, 139),
              )
            : const Icon(
                IconData(0xf733,
                    fontFamily: CupertinoIcons.iconFont,
                    fontPackage: CupertinoIcons.iconFontPackage),
                color: Color.fromARGB(242, 21, 86, 139),
                size: 20,
              ),
      );
    });
  }
}
