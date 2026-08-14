import 'package:flutter/material.dart';

/// Styling for the search box shown at the top of the menu when
/// `enableSearch` is on.
///
/// Every field is optional; `null` values fall back to sensible defaults
/// derived from the ambient [Theme].
@immutable
class DropdownSearchStyle {
  /// Creates a search box style. All parameters are optional.
  const DropdownSearchStyle({
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderWidth = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.textStyle,
    this.hintStyle,
    this.iconColor,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
  });

  /// Fill color of the search box. When set, the field is filled.
  final Color? fillColor;

  /// Border color in the normal (unfocused) state. Defaults to the theme
  /// divider color.
  final Color? borderColor;

  /// Border color while focused. Defaults to the theme primary color.
  final Color? focusedBorderColor;

  /// Border width in logical pixels.
  final double borderWidth;

  /// Corner radius of the search box.
  final BorderRadius borderRadius;

  /// Text style for what the user types.
  final TextStyle? textStyle;

  /// Text style for the placeholder. Defaults to the theme body text in the
  /// hint color.
  final TextStyle? hintStyle;

  /// Color of the leading search icon. Defaults to the theme icon color.
  final Color? iconColor;

  /// Inner content padding of the search field.
  final EdgeInsetsGeometry contentPadding;

  /// Returns a copy with the given fields replaced.
  DropdownSearchStyle copyWith({
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    Color? iconColor,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return DropdownSearchStyle(
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      iconColor: iconColor ?? this.iconColor,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}
