## 0.5.1

- Add a package screenshot so pub.dev shows a thumbnail on the search card and
  package page (declared via `screenshots:` in `pubspec.yaml`).
- Docs: the example's `main.dart` now opens with a comment pointing readers to
  the README on pub.dev for the full, copy-paste examples of every feature.

## 0.5.0

- Add a clearable single-select: set `clearable: true` to show a ✕ button on
  the trigger while a value is selected. Tapping it calls the new `onCleared`
  callback, where you reset your value (typically to `null`). Available on the
  default and `CustomDropdown.async` constructors; backward-compatible (opt-in).
- Add `Form` integration: pass a `validator` (and optional `autovalidateMode`)
  to make the dropdown a `FormField`. On a failed validation it shows the error
  message below the trigger and turns the field outline the theme's error color.
  Works with `Form.validate()`/`save()`. Available on all three constructors
  (`validator` validates `T?` for single/async and `List<T>` for `.multi`).
- Keyboard navigation and accessibility: the open menu responds to ↑/↓ (moving
  the highlight, skipping headers and disabled items), Enter (select), and Esc
  (close) — including while the search box has focus — and auto-scrolls the
  highlight into view. Added `Semantics` to the trigger (button, expanded state,
  current label) and to each item (selected/checked, enabled, label).
- Multi-select chips: set `showChips: true` on `CustomDropdown.multi` to show
  the selection as removable chips on the trigger (each with a ✕ that removes
  just that item) instead of comma-joined text. `chipOverflow` chooses wrap
  (default) or horizontal scroll; `chipStyle` (`DropdownChipStyle`) themes the
  chips, defaulting to colors derived from `menuStyle`/theme. `selectedItemsLabel`
  still applies when `showChips` is false.
- `DropdownController`: pass a `controller` to open/close/toggle the menu
  programmatically and read `isOpen`. It is a `ChangeNotifier`, so you can
  listen for open/close changes. Available on all three constructors.
- Multi-select `maxSelection`: cap how many items can be selected. At the
  limit, unselected items are disabled (selected ones can still be unchecked),
  and "select all" stops at the cap.

## 0.4.0

- Granular, independent styling split into three groups, replacing the old
  `DropdownDecoration`:
  - `fieldStyle` (`DropdownFieldStyle`) — input field: background, border color
    and width, radius, value/hint text styles, arrow icon color, padding.
  - `menuStyle` (`DropdownMenuStyle`) — menu box and rows: background, border,
    radius, elevation, item/selected/group-header text styles, highlight and
    selected colors, disabled color, sizing.
  - `searchStyle` (`DropdownSearchStyle`) — search bar: fill, border and
    focused-border colors, radius, text and hint styles, icon color, padding.
- The input field and the menu can now be themed separately (previously they
  shared one decoration), and the search bar is fully themable.

  Migration: replace `decoration: DropdownDecoration(...)` with the relevant
  `fieldStyle` / `menuStyle` / `searchStyle`. (`textStyle` on menu items is now
  `menuStyle.itemTextStyle`.)

## 0.3.0

- Add async loading via the `CustomDropdown.async` constructor: a
  `loader(query)` fetches items for the debounced search query, with a
  loading spinner, an error state plus retry, and the empty state. Results
  are used as-is (the loader owns filtering). Debounce and error/retry
  labels are configurable.
- Customizable loading indicator via the `loading` parameter and the new
  `DropdownLoading` type: `DropdownLoading.circular` (with a custom color),
  `DropdownLoading.shimmer` (animated skeleton with custom base/highlight
  colors, zero dependencies), or `DropdownLoading.custom` (your own widget).
- Customizable empty and error states: `emptyBuilder` (all constructors) and
  `errorBuilder` (async) let you render your own widgets. `errorBuilder`
  receives the thrown error and a retry callback.

## 0.2.0

- Add multi-select via the `CustomDropdown.multi` constructor: checkboxes,
  the menu stays open while toggling, `onSelectionChanged` reports the full
  selection, and `selectedItemsLabel` customizes the trigger text.
- Optional "select all" / "clear" actions for multi-select via
  `showSelectAll` (default off), with customizable `selectAllLabel` /
  `clearAllLabel`. Both respect the active search filter and skip disabled
  items.
- Multi-select reuses all existing features (search, grouping, positioning,
  per-item enable/disable, custom colors).

## 0.1.0

Initial release — single-select foundation.

- Generic `CustomDropdown<T>` that works over any model type.
- Free positioning: `top`, `bottom`, `left`, `right`, and `auto` (auto-flip).
- Built-in search (`enableSearch`) with an optional custom matcher.
- Grouping via `groupBy` with group headers.
- Per-item enable/disable via `isItemEnabled`.
- Custom colors and styling through `DropdownDecoration`.
- Optional custom item rows via `itemBuilder`.
- Zero runtime dependencies (Flutter SDK only).
