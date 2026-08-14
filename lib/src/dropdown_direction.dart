/// Controls where the dropdown menu opens relative to its trigger.
///
/// With [DropdownDirection.auto], the menu prefers to open below the trigger
/// but automatically flips to the opposite side when there is not enough room
/// on screen (e.g. the trigger is near the bottom edge).
enum DropdownDirection {
  /// Open above the trigger.
  top,

  /// Open below the trigger.
  bottom,

  /// Open to the left of the trigger.
  left,

  /// Open to the right of the trigger.
  right,

  /// Choose the best side automatically based on available space,
  /// preferring below then above.
  auto,
}
