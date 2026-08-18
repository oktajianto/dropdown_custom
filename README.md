# dropdown_custom

[![flutter](https://img.shields.io/badge/flutter-website-deepskyblue.svg)](https://flutter.dev)
[![dart](https://img.shields.io/badge/dart-website-00B4AB.svg)](https://dart.dev)
[![platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Mac%20%7C%20Linux%20%7C%20Windows-brightgreen.svg)](https://flutter.dev)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![pub](https://img.shields.io/pub/v/dropdown_custom.svg)](https://pub.dev/packages/dropdown_custom)
[![pub points](https://img.shields.io/pub/points/dropdown_custom.svg)](https://pub.dev/packages/dropdown_custom/score)
[![likes](https://img.shields.io/pub/likes/dropdown_custom.svg)](https://pub.dev/packages/dropdown_custom/score)
[![stars](https://img.shields.io/github/stars/oktajianto/dropdown_custom.svg?style=social)](https://github.com/oktajianto/dropdown_custom)
[![CI](https://github.com/oktajianto/dropdown_custom/actions/workflows/ci.yml/badge.svg)](https://github.com/oktajianto/dropdown_custom/actions/workflows/ci.yml)

A customizable, **zero-dependency** dropdown for Flutter. Simple to set up, yet
scales to real-world needs: **single or multiple selection**, search, grouping,
per-item enable/disable, custom colors, and free positioning — **top, bottom,
left, or right** with auto-flip.

**Works on every Flutter platform:** Android · iOS · Web · Windows · macOS ·
Linux. It is a pure-Dart package (no native code, no platform channels, no
third-party dependencies), so it runs anywhere Flutter runs.

## Why another dropdown?

Flutter's built-in dropdown is limited, and most alternatives only open below
the trigger. `dropdown_custom` focuses on:

- **Single or multiple selection** — pick one value, or enable multi-select to
  collect a `List<T>` with checkboxes.
- **Free positioning** — open the menu on any side, with `auto` flipping when
  it would run off-screen.
- **Type-safe generics** — items are a plain `List<T>`; no wrapper class
  required. `onChanged` returns your `T`, not `dynamic`.
- **Simple by default** — the basic case is three lines; every extra feature is
  an optional parameter.
- **No dependencies** — only the Flutter SDK.

## Preview

<p align="center">
  <img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/example-1.gif" alt="dropdown_custom demo" width="360" />
</p>

## Getting started

Add it with a single command:

```bash
flutter pub add dropdown_custom
```

Then import it:

```dart
import 'package:dropdown_custom/dropdown_custom.dart';
```

## Usage

### Simplest case

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/simplest.gif" alt="Simplest dropdown demo" width="360" /></p>

```dart
CustomDropdown<String>(
  items: const ['Apple', 'Mango', 'Orange'],
  onChanged: (value) => print(value),
)
```

### Clearable (single-select)

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/clearable.gif" alt="Clearable dropdown demo" width="360" /></p>

Show a ✕ button on the trigger to reset the selection. Because `onChanged`
returns a non-null `T`, clearing is reported through a separate `onCleared`
callback where you set your value back to `null`:

```dart
CustomDropdown<String>(
  items: const ['Apple', 'Mango', 'Orange'],
  value: selected,
  clearable: true,
  onChanged: (value) => setState(() => selected = value),
  onCleared: () => setState(() => selected = null),
)
```

### Inside a Form, with validation

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/form-validation.gif" alt="Form validation demo" width="360" /></p>

Pass a `validator` to make the dropdown a `FormField`: it joins the enclosing
`Form`, so `Form.validate()`/`save()` include it. On a failed validation the
error message appears below the trigger **and the field outline turns red**
(the theme's error color). Use `autovalidateMode` to validate as the user
interacts instead of only on submit:

```dart
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: Column(
    children: [
      CustomDropdown<City>(
        items: cities,
        value: selected,
        itemLabel: (c) => c.name,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (c) => c == null ? 'Please pick a city' : null,
        onChanged: (c) => setState(() => selected = c),
      ),
      ElevatedButton(
        onPressed: () => formKey.currentState!.validate(),
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

For multi-select, `validator` receives the selected `List<T>`:

```dart
CustomDropdown<City>.multi(
  items: cities,
  selectedItems: picked,
  itemLabel: (c) => c.name,
  validator: (list) =>
      (list == null || list.isEmpty) ? 'Pick at least one' : null,
  onSelectionChanged: (list) => setState(() => picked = list),
)
```

### Over your own model, with search and disabled items

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/search-disabled.gif" alt="Search and disabled items demo" width="360" /></p>

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

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/grouped.gif" alt="Grouped items demo" width="360" /></p>

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

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/multi-select.gif" alt="Multi-select demo" width="360" /></p>

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

Limit how many items can be picked with `maxSelection`. Once the limit is
reached, unselected items are disabled (already-selected ones can still be
unchecked), and "select all" stops at the limit:

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/max-selection.gif" alt="Max selection demo" width="360" /></p>

```dart
CustomDropdown<City>.multi(
  items: cities,
  selectedItems: picked,
  itemLabel: (c) => c.name,
  maxSelection: 3,
  onSelectionChanged: (list) => setState(() => picked = list),
)
```

By default the trigger shows the selection as comma-joined text (customizable
via `selectedItemsLabel`). Set `showChips: true` to show it as **removable
chips** instead — each chip has a ✕ that removes just that item, without
opening the menu:

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/chips.gif" alt="Multi-select chips demo" width="360" /></p>

```dart
CustomDropdown<City>.multi(
  items: cities,
  selectedItems: picked,
  itemLabel: (c) => c.name,
  showChips: true,
  chipOverflow: ChipOverflow.wrap, // or ChipOverflow.scroll (single line)
  chipStyle: const DropdownChipStyle(), // colors default from menuStyle/theme
  onSelectionChanged: (list) => setState(() => picked = list),
)
```

### Async loading

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/async.gif" alt="Async loading demo" width="360" /></p>

```dart
CustomDropdown<User>.async(
  loader: (query) => api.searchUsers(query), // Future<List<User>>
  itemLabel: (u) => u.name,
  debounce: const Duration(milliseconds: 300),
  onChanged: (u) => setState(() => selected = u),
)
```

`loader` is called with the debounced search query and owns filtering, so
results are shown as-is. The menu handles the loading state, an error state
with a retry action, and the empty state for you.

Choose how the loading state looks with `loading` — a circular spinner, an
animated skeleton shimmer (both with customizable colors), or your own widget:

```dart
CustomDropdown<User>.async(
  loader: (query) => api.searchUsers(query),
  // 1) circular spinner with a custom color
  loading: const DropdownLoading.circular(color: Colors.teal),
  // 2) animated skeleton shimmer (zero dependencies)
  // loading: DropdownLoading.shimmer(
  //   baseColor: Colors.grey.shade300,
  //   highlightColor: Colors.grey.shade100,
  //   itemCount: 5,
  // ),
  // 3) fully custom loading widget
  // loading: DropdownLoading.custom((context) => const MyLoader()),
  onChanged: (u) => ...,
)
```

The empty and error states are customizable too, so every async state
(loading / empty / error) can use your own widgets:

```dart
CustomDropdown<User>.async(
  loader: (query) => api.searchUsers(query),
  emptyBuilder: (context) => const Center(child: Text('No users found')),
  errorBuilder: (context, error, retry) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$error'),
      TextButton(onPressed: retry, child: const Text('Try again')),
    ],
  ),
  onChanged: (u) => ...,
)
```

`emptyBuilder` also works on the single- and multi-select constructors (shown
when a search yields no matches).

### Positioning

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/positioning.gif" alt="Positioning demo" width="360" /></p>

```dart
CustomDropdown<City>(
  items: cities,
  itemLabel: (c) => c.name,
  direction: DropdownDirection.right, // top / bottom / left / right / auto
  onChanged: (c) => ...,
)
```

### Styling (field / menu / search — independently)

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/styling.gif" alt="Styling demo" width="360" /></p>

Styling is split into three groups so the input field, the menu box, and the
search bar can be themed separately:

```dart
CustomDropdown<City>(
  items: cities,
  itemLabel: (c) => c.name,
  enableSearch: true,

  // The input field (trigger).
  fieldStyle: DropdownFieldStyle(
    backgroundColor: Colors.white,
    borderColor: Colors.teal,
    borderWidth: 1.5,
    textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
    iconColor: Colors.teal,
  ),

  // The dropdown box and its list rows.
  menuStyle: DropdownMenuStyle(
    backgroundColor: Colors.grey.shade50,
    borderColor: Colors.teal.shade100,
    itemTextStyle: const TextStyle(fontSize: 14),
    selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
    highlightColor: Colors.teal.shade50,
    maxHeight: 280,
  ),

  // The search bar.
  searchStyle: DropdownSearchStyle(
    fillColor: Colors.grey.shade100,
    borderColor: Colors.grey.shade300,
    focusedBorderColor: Colors.teal,
    hintStyle: const TextStyle(color: Colors.grey),
    textStyle: const TextStyle(fontSize: 14),
  ),

  onChanged: (c) => ...,
)
```

### Programmatic control (DropdownController)

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/controller.gif" alt="DropdownController demo" width="360" /></p>

Pass a `DropdownController` to open, close, or toggle the menu from anywhere,
and to observe its open state (it's a `ChangeNotifier`):

```dart
final controller = DropdownController();

CustomDropdown<City>(
  controller: controller,
  items: cities,
  itemLabel: (c) => c.name,
  onChanged: (c) => ...,
)

// From another widget / callback:
controller.open();
controller.close();
controller.toggle();
print(controller.isOpen);
controller.addListener(() => print('open: ${controller.isOpen}'));
```

Dispose it when done, like any `ChangeNotifier`. Works on all three
constructors (default, `.multi`, `.async`).

## Keyboard & accessibility

<p align="center"><img src="https://raw.githubusercontent.com/oktajianto/dropdown_custom/main/screenshots/keyboard.gif" alt="Keyboard navigation demo" width="360" /></p>

The open menu is fully keyboard-navigable (including while typing in the search
box):

| Key | Action |
|---|---|
| ↓ / ↑ | Move the highlight (skips group headers and disabled items) |
| Enter | Select the highlighted item (multi-select toggles it) |
| Esc | Close the menu |

The highlight auto-scrolls into view, and opens on the currently selected item.
The trigger and each item expose `Semantics` for screen readers — the trigger
as a button with its expanded state and current label, and each row with its
selected/checked and enabled state.

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
| `fieldStyle` | Styling for the input field (colors, border, font, padding). |
| `menuStyle` | Styling for the menu box and rows (colors, border, fonts, size). |
| `searchStyle` | Styling for the search bar (fill, border, hint, text, icon). |
| `itemBuilder` | Fully custom item rows. |
| `enabled` | Enables/disables the whole dropdown. |

## Roadmap

- [x] Single-select: search, grouping, positioning, custom colors, disable
- [x] Multi-select (with optional select-all/clear)
- [x] Async loading

See `implementasi_plan.md` for the full plan.

## License

MIT
