import 'package:flutter/material.dart';

class custom_button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;

  const custom_button({super.key, required this.text, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Semantics( // accesibilidad
      button: true,
      label: text,
      child: SizedBox(
        height: 48, // area minima 44x44
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          child: loading ? const CircularProgressIndicator() : Text(text),
        ),
      ),
    );
  }
}