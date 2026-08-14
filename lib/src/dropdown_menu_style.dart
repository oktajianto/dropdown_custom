import 'package:flutter/material.dart';

/// Styling for the open dropdown menu (the floating box and its rows).
///
/// Every field is optional; `null` values fall back to sensible defaults
/// derived from the ambient [Theme].
@immutable
class DropdownMenuStyle {
  /// Creates a menu style. All parameters are optional.
  const DropdownMenuStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 4,
    this.maxHeight = 320,
    this.itemTextStyle,
    this.selectedTextStyle,
    this.groupHeaderStyle,
    this.highlightColor,
    this.selectedColor,
    this.disabledColor,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  /// Background color of the menu box. Defaults to the theme surface color.
  final Color? backgroundColor;

  /// Outline color of the menu box. When `null` no border is drawn.
  final Color? borderColor;

  /// Outline width, used only when [borderColor] is set.
  final double borderWidth;

  /// Corner radius of the menu box.
  final BorderRadius borderRadius;

  /// Material elevation (shadow depth) of the menu.
  final double elevation;

  /// Maximum height before the list scrolls internally.
  final double maxHeight;

  /// Text style for normal (unselected, enabled) items.
  final TextStyle? itemTextStyle;

  /// Text style for the selected item. Falls back to [itemTextStyle] bolded.
  final TextStyle? selectedTextStyle;

  /// Text style for group header rows.
  final TextStyle? groupHeaderStyle;

  /// Background painted behind a hovered/focused item. Defaults to the theme
  /// primary color at low opacity.
  final Color? highlightColor;

  /// Background painted behind the selected item. Defaults to the theme
  /// primary color at low opacity.
  final Color? selectedColor;

  /// Text color for disabled items. Defaults to the theme disabled color.
  final Color? disabledColor;

  /// Padding around the list inside the menu.
  final EdgeInsetsGeometry menuPadding;

  /// Padding inside each item row.
  final EdgeInsetsGeometry itemPadding;

  /// Returns a copy with the given fields replaced.
  DropdownMenuStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    double? elevation,
    double? maxHeight,
    TextStyle? itemTextStyle,
    TextStyle? selectedTextStyle,
    TextStyle? groupHeaderStyle,
    Color? highlightColor,
    Color? selectedColor,
    Color? disabledColor,
    EdgeInsetsGeometry? menuPadding,
    EdgeInsetsGeometry? itemPadding,
  }) {
    return DropdownMenuStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      maxHeight: maxHeight ?? this.maxHeight,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      groupHeaderStyle: groupHeaderStyle ?? this.groupHeaderStyle,
      highlightColor: highlightColor ?? this.highlightColor,
      selectedColor: selectedColor ?? this.selectedColor,
      disabledColor: disabledColor ?? this.disabledColor,
      menuPadding: menuPadding ?? this.menuPadding,
      itemPadding: itemPadding ?? this.itemPadding,
    );
  }
}
