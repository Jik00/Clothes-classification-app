import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String? icon;
  final String text;
  final TextStyle textStyle;
  final Color iconColor;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    this.icon,
    required this.text,
    required this.textStyle,
    required this.iconColor,
    required this.backgroundColor,
    required this.onPressed,
     this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor?? Colors.transparent),
        ),
        padding: EdgeInsets.all(10),
        elevation: 0,
        splashFactory: NoSplash.splashFactory,
        shadowColor: Colors.transparent,
      ),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ImageIcon(AssetImage(icon!),size: 20, color: iconColor),
          Text(text, style: textStyle),
        ],
      ),
    );
  }
}