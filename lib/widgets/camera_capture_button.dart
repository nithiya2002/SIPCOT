import 'package:flutter/material.dart';

class CameraCaptureButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CameraCaptureButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}