# dropdown_custom example

A small gallery app for the `dropdown_custom` package.

Run it with:

```bash
cd example
flutter run
```

## Structure

The home screen (`lib/main.dart`) is a menu that opens one **focused demo per
feature** — handy for screenshots/GIFs of a single feature at a time:

| Menu entry | What it shows | Screenshot name |
|---|---|---|
| All features (one page) | Everything stacked together | — |
| Simplest | `items` + `onChanged` | `simplest.gif` |
| Clearable | ✕ button to reset | `clearable.gif` |
| Search + disabled | Filter + per-item enable/disable | `search-disabled.gif` |
| Grouped | Group headers | `grouped.gif` |
| Form validation | `validator` + red outline | `form-validation.gif` |
| Multi-select | Checkboxes + select all | `multi-select.gif` |
| Chips | Removable chips | `chips.gif` |
| Max selection | Cap the count | `max-selection.gif` |
| Async loading | Remote + shimmer | `async.gif` |
| Positioning | Opens to the right | `positioning.gif` |
| Styling | Field / menu / search | `styling.gif` |
| Keyboard & a11y | ↑/↓, Enter, Esc | `keyboard.gif` |
| DropdownController | Open/close programmatically | `controller.gif` |

The README GIFs live in the package's top-level `screenshots/` folder and are
referenced from `README.md` by the names in the last column.

- `lib/city.dart` — the shared `City` model + sample data.
- `lib/demos.dart` — the per-feature demo pages.
- `lib/all_features_page.dart` — the original single-page demo.
