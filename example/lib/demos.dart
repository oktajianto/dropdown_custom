import 'package:dropdown_custom/dropdown_custom.dart';
import 'package:flutter/material.dart';

import 'city.dart';

/// Shared layout for a single focused demo: an app bar, a centered max-width
/// column, and an optional hint line above the dropdown.
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.child,
    this.hint,
  });

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      hint!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simplest
// ---------------------------------------------------------------------------

class SimplestDemo extends StatefulWidget {
  const SimplestDemo({super.key});
  @override
  State<SimplestDemo> createState() => _SimplestDemoState();
}

class _SimplestDemoState extends State<SimplestDemo> {
  String? _fruit;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Simplest',
      hint: 'Three lines: items + onChanged.',
      child: CustomDropdown<String>(
        items: const <String>['Apple', 'Mango', 'Orange', 'Banana'],
        value: _fruit,
        hintText: 'Pick a fruit',
        onChanged: (String v) => setState(() => _fruit = v),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Clearable
// ---------------------------------------------------------------------------

class ClearableDemo extends StatefulWidget {
  const ClearableDemo({super.key});
  @override
  State<ClearableDemo> createState() => _ClearableDemoState();
}

class _ClearableDemoState extends State<ClearableDemo> {
  String? _fruit;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Clearable',
      hint: 'Pick a value, then tap the ✕ to reset.',
      child: CustomDropdown<String>(
        items: const <String>['Apple', 'Mango', 'Orange', 'Banana'],
        value: _fruit,
        hintText: 'Pick a fruit',
        clearable: true,
        onChanged: (String v) => setState(() => _fruit = v),
        onCleared: () => setState(() => _fruit = null),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search + disabled items over a model
// ---------------------------------------------------------------------------

class SearchDisabledDemo extends StatefulWidget {
  const SearchDisabledDemo({super.key});
  @override
  State<SearchDisabledDemo> createState() => _SearchDisabledDemoState();
}

class _SearchDisabledDemoState extends State<SearchDisabledDemo> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Search + disabled',
      hint: 'Type to filter; greyed cities are disabled.',
      child: CustomDropdown<City>(
        items: kCities,
        value: _city,
        itemLabel: (City c) => c.name,
        isItemEnabled: (City c) => c.available,
        enableSearch: true,
        searchHint: 'Search city…',
        hintText: 'Pick a city',
        onChanged: (City c) => setState(() => _city = c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped
// ---------------------------------------------------------------------------

class GroupedDemo extends StatefulWidget {
  const GroupedDemo({super.key});
  @override
  State<GroupedDemo> createState() => _GroupedDemoState();
}

class _GroupedDemoState extends State<GroupedDemo> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Grouped',
      hint: 'Items grouped under province headers.',
      child: CustomDropdown<City>(
        items: kCities,
        value: _city,
        itemLabel: (City c) => c.name,
        groupBy: (City c) => c.province,
        enableSearch: true,
        hintText: 'Pick a city (grouped)',
        onChanged: (City c) => setState(() => _city = c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form validation
// ---------------------------------------------------------------------------

class FormValidationDemo extends StatefulWidget {
  const FormValidationDemo({super.key});
  @override
  State<FormValidationDemo> createState() => _FormValidationDemoState();
}

class _FormValidationDemoState extends State<FormValidationDemo> {
  City? _city;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Form validation',
      hint: 'Submit with nothing picked to see the error + red outline.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomDropdown<City>(
              items: kCities,
              value: _city,
              itemLabel: (City c) => c.name,
              hintText: 'Pick a city (required)',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (City? c) => c == null ? 'Please pick a city' : null,
              onChanged: (City c) => setState(() => _city = c),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final bool ok = _formKey.currentState!.validate();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Valid!' : 'Fix the errors')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select (basic + select all)
// ---------------------------------------------------------------------------

class MultiSelectDemo extends StatefulWidget {
  const MultiSelectDemo({super.key});
  @override
  State<MultiSelectDemo> createState() => _MultiSelectDemoState();
}

class _MultiSelectDemoState extends State<MultiSelectDemo> {
  List<City> _cities = <City>[];

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Multi-select',
      hint: 'Checkboxes, grouping, search, and select-all / clear.',
      child: CustomDropdown<City>.multi(
        items: kCities,
        selectedItems: _cities,
        itemLabel: (City c) => c.name,
        groupBy: (City c) => c.province,
        enableSearch: true,
        showSelectAll: true,
        hintText: 'Pick cities',
        onSelectionChanged: (List<City> list) => setState(() => _cities = list),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select chips
// ---------------------------------------------------------------------------

class ChipsDemo extends StatefulWidget {
  const ChipsDemo({super.key});
  @override
  State<ChipsDemo> createState() => _ChipsDemoState();
}

class _ChipsDemoState extends State<ChipsDemo> {
  List<City> _cities = <City>[];

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Chips',
      hint: 'Selection shows as chips; tap a chip ✕ to remove it.',
      child: CustomDropdown<City>.multi(
        items: kCities,
        selectedItems: _cities,
        itemLabel: (City c) => c.name,
        enableSearch: true,
        showChips: true,
        chipOverflow: ChipOverflow.wrap,
        hintText: 'Pick cities',
        onSelectionChanged: (List<City> list) => setState(() => _cities = list),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select maxSelection
// ---------------------------------------------------------------------------

class MaxSelectionDemo extends StatefulWidget {
  const MaxSelectionDemo({super.key});
  @override
  State<MaxSelectionDemo> createState() => _MaxSelectionDemoState();
}

class _MaxSelectionDemoState extends State<MaxSelectionDemo> {
  List<City> _cities = <City>[];

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Max selection',
      hint: 'Pick 3; the rest become disabled until you remove one.',
      child: CustomDropdown<City>.multi(
        items: kCities,
        selectedItems: _cities,
        itemLabel: (City c) => c.name,
        showChips: true,
        maxSelection: 3,
        hintText: 'Pick up to 3 cities',
        onSelectionChanged: (List<City> list) => setState(() => _cities = list),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Async loading
// ---------------------------------------------------------------------------

class AsyncDemo extends StatefulWidget {
  const AsyncDemo({super.key});
  @override
  State<AsyncDemo> createState() => _AsyncDemoState();
}

class _AsyncDemoState extends State<AsyncDemo> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Async loading',
      hint: 'Type to fetch remotely; shimmer skeleton while loading.',
      child: CustomDropdown<City>.async(
        loader: searchCities,
        value: _city,
        itemLabel: (City c) => c.name,
        searchHint: 'Type to search cities…',
        hintText: 'Search remotely',
        loading: const DropdownLoading.shimmer(itemCount: 5),
        onChanged: (City c) => setState(() => _city = c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Positioning
// ---------------------------------------------------------------------------

class PositioningDemo extends StatefulWidget {
  const PositioningDemo({super.key});
  @override
  State<PositioningDemo> createState() => _PositioningDemoState();
}

class _PositioningDemoState extends State<PositioningDemo> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Positioning',
      hint: 'This menu opens to the RIGHT of the trigger.',
      child: CustomDropdown<City>(
        items: kCities,
        value: _city,
        itemLabel: (City c) => c.name,
        direction: DropdownDirection.right,
        menuWidth: 200,
        leading: const Icon(Icons.place_outlined, size: 18),
        hintText: 'Side menu',
        onChanged: (City c) => setState(() => _city = c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Styling
// ---------------------------------------------------------------------------

class StylingDemo extends StatefulWidget {
  const StylingDemo({super.key});
  @override
  State<StylingDemo> createState() => _StylingDemoState();
}

class _StylingDemoState extends State<StylingDemo> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Styling',
      hint: 'Field, menu, and search bar themed independently.',
      child: CustomDropdown<City>(
        items: kCities,
        value: _city,
        itemLabel: (City c) => c.name,
        groupBy: (City c) => c.province,
        enableSearch: true,
        hintText: 'Pick a city (grouped)',
        fieldStyle: DropdownFieldStyle(
          backgroundColor: Colors.teal.shade50,
          borderColor: Colors.teal,
          borderWidth: 1.5,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        menuStyle: DropdownMenuStyle(
          backgroundColor: Colors.teal.shade50,
          borderColor: Colors.teal.shade200,
          highlightColor: Colors.teal.withValues(alpha: 0.12),
          selectedColor: Colors.teal.withValues(alpha: 0.22),
          itemTextStyle: const TextStyle(fontSize: 14),
        ),
        searchStyle: DropdownSearchStyle(
          fillColor: Colors.white,
          borderColor: Colors.teal.shade200,
          focusedBorderColor: Colors.teal,
          hintStyle: TextStyle(color: Colors.teal.shade300),
        ),
        onChanged: (City c) => setState(() => _city = c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Keyboard & accessibility
// ---------------------------------------------------------------------------

class KeyboardDemo extends StatefulWidget {
  const KeyboardDemo({super.key});
  @override
  State<KeyboardDemo> createState() => _KeyboardDemoState();
}

class _KeyboardDemoState extends State<KeyboardDemo> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Keyboard & a11y',
      hint: 'Open it, then use ↑/↓ to move, Enter to select, Esc to close.',
      child: CustomDropdown<City>(
        items: kCities,
        value: _city,
        itemLabel: (City c) => c.name,
        enableSearch: true,
        hintText: 'Pick a city',
        onChanged: (City c) => setState(() => _city = c),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DropdownController
// ---------------------------------------------------------------------------

class ControllerDemo extends StatefulWidget {
  const ControllerDemo({super.key});
  @override
  State<ControllerDemo> createState() => _ControllerDemoState();
}

class _ControllerDemoState extends State<ControllerDemo> {
  City? _city;
  final DropdownController _controller = DropdownController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'DropdownController',
      hint: 'Open / close the menu from the button below.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomDropdown<City>(
            controller: _controller,
            items: kCities,
            value: _city,
            itemLabel: (City c) => c.name,
            hintText: 'Controlled from the button below',
            onChanged: (City c) => setState(() => _city = c),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _controller.toggle,
            icon: const Icon(Icons.arrow_drop_down_circle_outlined),
            label: const Text('Open / close from here'),
          ),
        ],
      ),
    );
  }
}
