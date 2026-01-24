import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isOutlined;
  final bool isDisabled;
  final double elevation;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.isFullWidth = false,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.textStyle,
    this.isOutlined = false,
    this.isDisabled = false,
    this.elevation = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final btnWidth = isFullWidth ? double.infinity : width;

    Widget child = isLoading
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined ? theme.primaryColor : Colors.white,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOutlined
                    ? (textColor ?? theme.primaryColor)
                    : (textColor ?? Colors.white),
              ),
        ),
      ],
    );

    final button = isOutlined
        ? OutlinedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(btnWidth ?? 0, height ?? 56),
        padding: padding,
        side: BorderSide(
          color: borderColor ?? theme.primaryColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: child,
    )
        : ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? Colors.grey[400]
            : (backgroundColor ?? theme.primaryColor),
        foregroundColor: textColor ?? Colors.white,
        minimumSize: Size(btnWidth ?? 0, height ?? 56),
        padding: padding,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: child,
    );

    return button;
  }

  // Factory constructors for common button types
  factory CustomButton.primary({
    required String text,
    required VoidCallback onPressed,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory CustomButton.success({
    required String text,
    required VoidCallback onPressed,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.green,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory CustomButton.danger({
    required String text,
    required VoidCallback onPressed,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.red,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory CustomButton.outlined({
    required String text,
    required VoidCallback onPressed,
    Color? color,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      textColor: color,
      borderColor: color,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      icon: icon,
      isOutlined: true,
    );
  }

  factory CustomButton.small({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double? width,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      width: width,
      height: 40,
      isLoading: isLoading,
      icon: icon,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}