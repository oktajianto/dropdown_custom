// Looking for the full, copy-paste examples for every feature? See the README
// on the package page: https://pub.dev/packages/dropdown_custom
//
// This app is a runnable gallery: a home menu that opens one focused demo per
// feature (see demos.dart), plus an "All features" page that stacks them all.
import 'package:flutter/material.dart';

import 'all_features_page.dart';
import 'demos.dart';

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
      home: const HomePage(),
    );
  }
}

/// A single demo entry in the home menu.
class _Demo {
  const _Demo(this.title, this.subtitle, this.builder);
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<_Demo> _demos = <_Demo>[
    _Demo(
      'All features (one page)',
      'Everything stacked together',
      (_) => const AllFeaturesPage(),
    ),
    _Demo('Simplest', 'items + onChanged', (_) => const SimplestDemo()),
    _Demo('Clearable', '✕ button to reset', (_) => const ClearableDemo()),
    _Demo(
      'Search + disabled',
      'Filter + per-item enable/disable',
      (_) => const SearchDisabledDemo(),
    ),
    _Demo('Grouped', 'Group headers', (_) => const GroupedDemo()),
    _Demo(
      'Form validation',
      'validator + red outline',
      (_) => const FormValidationDemo(),
    ),
    _Demo(
      'Multi-select',
      'Checkboxes + select all',
      (_) => const MultiSelectDemo(),
    ),
    _Demo('Chips', 'Removable chips', (_) => const ChipsDemo()),
    _Demo('Max selection', 'Cap the count', (_) => const MaxSelectionDemo()),
    _Demo('Async loading', 'Remote + shimmer', (_) => const AsyncDemo()),
    _Demo('Positioning', 'Opens to the right', (_) => const PositioningDemo()),
    _Demo('Styling', 'Field / menu / search', (_) => const StylingDemo()),
    _Demo('Keyboard & a11y', '↑/↓, Enter, Esc', (_) => const KeyboardDemo()),
    _Demo(
      'DropdownController',
      'Open/close programmatically',
      (_) => const ControllerDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('dropdown_custom examples')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _demos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) {
              final _Demo demo = _demos[i];
              return ListTile(
                title: Text(demo.title),
                subtitle: Text(demo.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: demo.builder)),
              );
            },
          ),
        ),
      ),
    );
  }
}
