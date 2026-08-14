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
