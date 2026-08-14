import 'package:flutter/material.dart';

/// Styling for the dropdown's input field (the tappable trigger).
///
/// Every field is optional; `null` values fall back to sensible defaults
/// derived from the ambient [Theme].
@immutable
class DropdownFieldStyle {
  /// Creates an input field style. All parameters are optional.
  const DropdownFieldStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.textStyle,
    this.hintStyle,
    this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  /// Fill color of the field. Defaults to transparent.
  final Color? backgroundColor;

  /// Outline color. Defaults to the theme divider color.
  final Color? borderColor;

  /// Outline width in logical pixels.
  final double borderWidth;

  /// Corner radius of the field (and its tap ripple).
  final BorderRadius borderRadius;

  /// Text style for the selected value. Defaults to the theme body text.
  final TextStyle? textStyle;

  /// Text style for the hint shown when nothing is selected. Defaults to the
  /// theme body text in the hint color.
  final TextStyle? hintStyle;

  /// Color of the trailing dropdown arrow. Defaults to the theme icon color.
  final Color? iconColor;

  /// Inner padding of the field.
  final EdgeInsetsGeometry padding;

  /// Returns a copy with the given fields replaced.
  DropdownFieldStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    Color? iconColor,
    EdgeInsetsGeometry? padding,
  }) {
    return DropdownFieldStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      iconColor: iconColor ?? this.iconColor,
      padding: padding ?? this.padding,
    );
  }
}
