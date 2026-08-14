import 'package:flutter/material.dart';

/// Describes how the async menu renders its loading state.
///
/// Pick one of three styles:
///
/// * [DropdownLoading.circular] — a centered circular spinner (the default).
/// * [DropdownLoading.shimmer] — animated skeleton placeholder rows.
/// * [DropdownLoading.custom] — your own widget via a builder.
///
/// All colors are optional and fall back to sensible values from the ambient
/// [Theme].
@immutable
class DropdownLoading {
  /// A centered circular progress indicator.
  ///
  /// [color] defaults to the theme primary color.
  const DropdownLoading.circular({this.color, this.strokeWidth = 2.5})
    : shimmer = false,
      baseColor = null,
      highlightColor = null,
      itemCount = 0,
      builder = null;

  /// Animated skeleton placeholder rows with a shimmer sweep.
  ///
  /// [baseColor] is the placeholder bar color and [highlightColor] is the
  /// moving light; both fall back to theme-derived greys. [itemCount] controls
  /// how many placeholder rows are shown.
  const DropdownLoading.shimmer({
    this.baseColor,
    this.highlightColor,
    this.itemCount = 5,
  }) : shimmer = true,
       color = null,
       strokeWidth = 2.5,
       builder = null;

  /// A fully custom loading widget built by [builder].
  const DropdownLoading.custom(WidgetBuilder this.builder)
    : shimmer = false,
      color = null,
      strokeWidth = 2.5,
      baseColor = null,
      highlightColor = null,
      itemCount = 0;

  /// Whether the shimmer skeleton style is used.
  final bool shimmer;

  /// Circular style: spinner color.
  final Color? color;

  /// Circular style: spinner stroke width.
  final double strokeWidth;

  /// Shimmer style: placeholder bar color.
  final Color? baseColor;

  /// Shimmer style: moving highlight color.
  final Color? highlightColor;

  /// Shimmer style: number of placeholder rows.
  final int itemCount;

  /// Custom style: builds the loading widget. Non-null only for
  /// [DropdownLoading.custom].
  final WidgetBuilder? builder;
}
