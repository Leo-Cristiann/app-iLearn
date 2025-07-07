import 'package:flutter/material.dart';

enum CustomButtonType {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double height;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 50.0,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Button styles based on type
    Color bgColor;
    Color textColor;
    Color borderColor;
    
    switch (type) {
      case CustomButtonType.primary:
        bgColor = theme.colorScheme.primary;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.secondary:
        bgColor = theme.colorScheme.secondary;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CustomButtonType.outline:
        bgColor = Colors.transparent;
        textColor = theme.colorScheme.primary;
        borderColor = theme.colorScheme.primary;
        break;
      case CustomButtonType.text:
        bgColor = Colors.transparent;
        textColor = theme.colorScheme.primary;
        borderColor = Colors.transparent;
        break;
    }
    
    // Apply disabled states
    if (disabled || isLoading) {
      bgColor = bgColor.withAlpha(128);
      textColor = textColor.withAlpha(128);
      borderColor = borderColor.withAlpha(128);
    }
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (disabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: borderColor,
            width: type == CustomButtonType.outline ? 1.5 : 0,
          ),
          elevation: type == CustomButtonType.text || type == CustomButtonType.outline ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.0,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 20),
                    const SizedBox(width: 8.0),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8.0),
                    Icon(suffixIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}