import 'package:flutter/material.dart';

/// How multi-select chips behave when they exceed the trigger's width.
enum ChipOverflow {
  /// Chips wrap onto new lines; the trigger grows taller to fit them.
  wrap,

  /// Chips stay on a single line and scroll horizontally.
  scroll,
}

/// Styling for the multi-select chips shown on the trigger when
/// `CustomDropdown.multi(showChips: true)` is used.
///
/// Every color is optional; `null` values fall back to sensible defaults
/// derived from `menuStyle` and the ambient [Theme].
@immutable
class DropdownChipStyle {
  /// Creates a chip style. All parameters are optional.
  const DropdownChipStyle({
    this.backgroundColor,
    this.textStyle,
    this.deleteIconColor,
    this.deleteIconSize = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.padding = const EdgeInsets.fromLTRB(8, 2, 4, 2),
    this.spacing = 6,
  });

  /// Chip fill color. Defaults to `menuStyle.selectedColor`, or a light tint
  /// of the theme primary color.
  final Color? backgroundColor;

  /// Text style for the chip label. Defaults to the theme body text.
  final TextStyle? textStyle;

  /// Color of the per-chip delete (✕) icon. Defaults to the label color.
  final Color? deleteIconColor;

  /// Size of the delete (✕) icon in logical pixels.
  final double deleteIconSize;

  /// Corner radius of each chip.
  final BorderRadius borderRadius;

  /// Inner padding of each chip.
  final EdgeInsetsGeometry padding;

  /// Space (both horizontal and vertical) between chips.
  final double spacing;

  /// Returns a copy with the given fields replaced.
  DropdownChipStyle copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    Color? deleteIconColor,
    double? deleteIconSize,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? spacing,
  }) {
    return DropdownChipStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      deleteIconColor: deleteIconColor ?? this.deleteIconColor,
      deleteIconSize: deleteIconSize ?? this.deleteIconSize,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
    );
  }
}
