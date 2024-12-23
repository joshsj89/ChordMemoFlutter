import 'package:flutter/material.dart';

class FlexibleWidthButton extends StatelessWidget {
  final String label;
  final bool disabled;
  final VoidCallback onPressed;
  final double? width;

  const FlexibleWidthButton({
    super.key,
    required this.label,
    this.disabled = false,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: !disabled ? onPressed : null,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(!disabled ? Color(0xff009788) : Color(0xffdfdfdf)),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
          ),
        ),
        child: Text(
          label.toUpperCase(), 
          style: TextStyle(
            color: !disabled ? Colors.white : Color(0xffacacac), 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}