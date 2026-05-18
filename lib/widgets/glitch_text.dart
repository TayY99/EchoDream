import 'package:flutter/material.dart';

class GlitchText extends StatelessWidget {
  final String text;

  const GlitchText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: 22,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(color: Colors.redAccent, offset: Offset(1, 0)),
          Shadow(color: Colors.blueAccent, offset: Offset(-1, 0)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
