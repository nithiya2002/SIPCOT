import 'package:flutter/material.dart';

class CircularTextIcon extends StatelessWidget {
  final String text;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const CircularTextIcon({
    super.key,
    required this.text,
    this.size = 40,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
