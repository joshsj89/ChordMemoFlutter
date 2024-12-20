import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final bool disabled;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    this.disabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: !disabled ? onPressed : null,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(!disabled ? Color(0xff009788) : Color(0xffdfdfdf)),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
          ),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: !disabled ? Colors.white : Color(0xffacacac), 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}