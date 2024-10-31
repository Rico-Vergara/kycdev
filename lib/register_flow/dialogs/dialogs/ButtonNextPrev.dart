import 'package:flutter/material.dart';

class ButtonNextPrev extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const ButtonNextPrev({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
