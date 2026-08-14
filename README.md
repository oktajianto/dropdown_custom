# dropdown_custom

[![CI](https://github.com/oktajianto/dropdown_custom/actions/workflows/ci.yml/badge.svg)](https://github.com/oktajianto/dropdown_custom/actions/workflows/ci.yml)

A customizable, **zero-dependency** dropdown for Flutter. Simple to set up, yet
scales to real-world needs: search, grouping, per-item enable/disable, custom
colors, and free positioning — **top, bottom, left, or right** with auto-flip.

**Works on every Flutter platform:** Android · iOS · Web · Windows · macOS ·
Linux. It is a pure-Dart package (no native code, no platform channels, no
third-party dependencies), so it runs anywhere Flutter runs.

## Why another dropdown?

Flutter's built-in dropdown is limited, and most alternatives only open below
the trigger. `dropdown_custom` focuses on:

- **Free positioning** — open the menu on any side, with `auto` flipping when
  it would run off-screen.
- **Type-safe generics** — items are a plain `List<T>`; no wrapper class
  required. `onChanged` returns your `T`, not `dynamic`.
- **Simple by default** — the basic case is three lines; every extra feature is
  an optional parameter.
- **No dependencies** — only the Flutter SDK.

## Getting started

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  dropdown_custom: ^0.1.0
```

## Usage

### Simplest case

```dart
CustomDropdown<String>(
  items: const ['Apple', 'Mango', 'Orange'],
  onChanged: (value) => print(value),
)
```

### Over your own model, with search and disabled items

```dart
CustomDropdown<City>(
  items: cities,
  value: selected,
  itemLabel: (c) => c.name,
  isItemEnabled: (c) => c.available,
  enableSearch: true,
  onChanged: (c) => setState(() => selected = c),
)
```

### Grouped

```dart
CustomDropdown<City>(
  items: cities,
  itemLabel: (c) => c.name,
  groupBy: (c) => c.province,
  enableSearch: true,
  onChanged: (c) => ...,
)
```

### Multi-select

```dart
CustomDropdown<City>.multi(
  items: cities,
  selectedItems: picked,
  itemLabel: (c) => c.name,
  groupBy: (c) => c.province,
  enableSearch: true,
  onSelectionChanged: (list) => setState(() => picked = list),
)
```

The menu shows a checkbox on each row and stays open while the user toggles
items; `onSelectionChanged` fires with the full selection on every change.

Add optional "select all" / "clear" actions with `showSelectAll: true`
(off by default). Both respect the active search filter and skip disabled
items, and their labels are customizable:

```dart
CustomDropdown<City>.multi(
  items: cities,
  selectedItems: picked,
  itemLabel: (c) => c.name,
  enableSearch: true,
  showSelectAll: true,
  selectAllLabel: 'Select all',
  clearAllLabel: 'Clear',
  onSelectionChanged: (list) => setState(() => picked = list),
)
```

### Positioning and custom colors

```dart
CustomDropdown<City>(
  items: cities,
  itemLabel: (c) => c.name,
  direction: DropdownDirection.right,
  decoration: const DropdownDecoration(
    highlightColor: Color(0x1A00BCD4),
    selectedColor: Color(0x3300BCD4),
    maxHeight: 280,
  ),
  onChanged: (c) => ...,
)
```

## Key parameters

| Parameter | Description |
|---|---|
| `items` | The `List<T>` of choices. |
| `onChanged` | Called with the selected `T`. |
| `value` | The currently selected item. |
| `itemLabel` | Maps an item to its label (defaults to `toString()`). |
| `groupBy` | Groups items under headers. |
| `isItemEnabled` | Disables specific items. |
| `enableSearch` | Shows a search box. |
| `searchMatcher` | Custom search predicate. |
| `showSelectAll` | Multi-select: show "select all" / "clear" actions. |
| `direction` | `top`, `bottom`, `left`, `right`, or `auto`. |
| `decoration` | Colors, radius, elevation, sizing. |
| `itemBuilder` | Fully custom item rows. |
| `enabled` | Enables/disables the whole dropdown. |

## Roadmap

- [x] Single-select: search, grouping, positioning, custom colors, disable
- [x] Multi-select
- [ ] Async loading

See `implementasi_plan.md` for the full plan.

## License

MIT
