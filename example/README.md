# dropdown_custom example

A small gallery app for the `dropdown_custom` package.

```bash
cd example
flutter run
```

The home screen (`lib/main.dart`) is a menu that opens one **focused demo per
feature** — handy for screenshots/GIFs of a single feature at a time:

| Menu entry | What it shows |
|---|---|
| All features (one page) | Everything stacked together |
| Simplest | `items` + `onChanged` |
| Clearable | ✕ button to reset |
| Search + disabled | Filter + per-item enable/disable |
| Grouped | Group headers |
| Form validation | `validator` + red outline |
| Multi-select | Checkboxes + select all |
| Chips | Removable chips |
| Max selection | Cap the count |
| Async loading | Remote + shimmer |
| Positioning | Opens to the right |
| Styling | Field / menu / search |
| Keyboard & a11y | ↑/↓, Enter, Esc |
| DropdownController | Open/close programmatically |

Source files: `lib/main.dart` (menu), `lib/demos.dart` (per-feature demos),
`lib/all_features_page.dart` (the single-page demo below), and `lib/city.dart`
(shared `City` model + sample data).

## Full example — every feature on one page

```dart
import 'package:dropdown_custom/dropdown_custom.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dropdown_custom demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

/// A simple model to show the dropdown works over any type `T`, not just String.
class City {
  const City(this.name, this.province, {this.available = true});
  final String name;
  final String province;
  final bool available;
}

const List<City> kCities = <City>[
  City('Jakarta', 'DKI Jakarta'),
  City('Bandung', 'Jawa Barat'),
  City('Surabaya', 'Jawa Timur'),
  City('Malang', 'Jawa Timur', available: false),
  City('Semarang', 'Jawa Tengah'),
  City('Denpasar', 'Bali'),
  City('Medan', 'Sumatera Utara', available: false),
  City('Makassar', 'Sulawesi Selatan'),
];

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  String? _fruit;
  City? _city;
  City? _sideCity;
  City? _asyncCity;
  List<City> _multiCities = <City>[];
  City? _formCity;
  City? _controlledCity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DropdownController _controller = DropdownController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fake network search: filters [kCities] by [query] after a short delay.
  Future<List<City>> _searchCities(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final String q = query.toLowerCase();
    return kCities.where((City c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('dropdown_custom')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              // 1. Simplest single-select, clearable.
              CustomDropdown<String>(
                items: const <String>['Apple', 'Mango', 'Orange', 'Banana'],
                value: _fruit,
                hintText: 'Pick a fruit',
                clearable: true,
                onChanged: (String v) => setState(() => _fruit = v),
                onCleared: () => setState(() => _fruit = null),
              ),
              const SizedBox(height: 24),

              // 2. Over a model, with search + disabled items.
              CustomDropdown<City>(
                items: kCities,
                value: _city,
                itemLabel: (City c) => c.name,
                isItemEnabled: (City c) => c.available,
                enableSearch: true,
                hintText: 'Pick a city',
                onChanged: (City c) => setState(() => _city = c),
              ),
              const SizedBox(height: 24),

              // 3. Multi-select with chips, grouping, and a cap of 3.
              CustomDropdown<City>.multi(
                items: kCities,
                selectedItems: _multiCities,
                itemLabel: (City c) => c.name,
                groupBy: (City c) => c.province,
                enableSearch: true,
                showSelectAll: true,
                showChips: true,
                maxSelection: 3,
                hintText: 'Pick up to 3 cities',
                onSelectionChanged: (List<City> list) =>
                    setState(() => _multiCities = list),
              ),
              const SizedBox(height: 24),

              // 4. Async loading with a shimmer skeleton.
              CustomDropdown<City>.async(
                loader: _searchCities,
                value: _asyncCity,
                itemLabel: (City c) => c.name,
                hintText: 'Search remotely',
                loading: const DropdownLoading.shimmer(itemCount: 5),
                onChanged: (City c) => setState(() => _asyncCity = c),
              ),
              const SizedBox(height: 24),

              // 5. Opens to the right of the trigger.
              CustomDropdown<City>(
                items: kCities,
                value: _sideCity,
                itemLabel: (City c) => c.name,
                direction: DropdownDirection.right,
                menuWidth: 200,
                hintText: 'Side menu',
                onChanged: (City c) => setState(() => _sideCity = c),
              ),
              const SizedBox(height: 24),

              // 6. Inside a Form, with validation.
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CustomDropdown<City>(
                      items: kCities,
                      value: _formCity,
                      itemLabel: (City c) => c.name,
                      hintText: 'Pick a city (required)',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (City? c) =>
                          c == null ? 'Please pick a city' : null,
                      onChanged: (City c) => setState(() => _formCity = c),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _formKey.currentState!.validate(),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7. Programmatic control via a DropdownController.
              CustomDropdown<City>(
                controller: _controller,
                items: kCities,
                value: _controlledCity,
                itemLabel: (City c) => c.name,
                hintText: 'Controlled from the button below',
                onChanged: (City c) => setState(() => _controlledCity = c),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _controller.toggle,
                child: const Text('Open / close from here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
