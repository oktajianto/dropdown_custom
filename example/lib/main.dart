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

/// A simple model to demonstrate that the dropdown works over any type [T],
/// not just [String].
class City {
  const City(this.name, this.province, {this.available = true});

  final String name;
  final String province;
  final bool available;
}

const List<City> kCities = <City>[
  City('Jakarta', 'DKI Jakarta'),
  City('Bandung', 'Jawa Barat'),
  City('Bekasi', 'Jawa Barat'),
  City('Surabaya', 'Jawa Timur'),
  City('Malang', 'Jawa Timur', available: false),
  City('Semarang', 'Jawa Tengah'),
  City('Solo', 'Jawa Tengah'),
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
  City? _groupedCity;
  City? _sideCity;
  City? _asyncCity;
  List<City> _multiCities = <City>[];

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
              _section('1. Simplest — List<String>'),
              CustomDropdown<String>(
                items: const <String>['Apple', 'Mango', 'Orange', 'Banana'],
                value: _fruit,
                hintText: 'Pick a fruit',
                onChanged: (String v) => setState(() => _fruit = v),
              ),

              _section('2. Model + search + disabled items'),
              CustomDropdown<City>(
                items: kCities,
                value: _city,
                itemLabel: (City c) => c.name,
                isItemEnabled: (City c) => c.available,
                enableSearch: true,
                searchHint: 'Search city…',
                hintText: 'Pick a city',
                onChanged: (City c) => setState(() => _city = c),
              ),

              _section('3. Grouped + custom highlight color'),
              CustomDropdown<City>(
                items: kCities,
                value: _groupedCity,
                itemLabel: (City c) => c.name,
                groupBy: (City c) => c.province,
                enableSearch: true,
                hintText: 'Pick a city (grouped)',
                decoration: const DropdownDecoration(
                  highlightColor: Color(0x1A00BCD4),
                  selectedColor: Color(0x3300BCD4),
                ),
                onChanged: (City c) => setState(() => _groupedCity = c),
              ),

              _section('4. Multi-select + search + grouping'),
              CustomDropdown<City>.multi(
                items: kCities,
                selectedItems: _multiCities,
                itemLabel: (City c) => c.name,
                groupBy: (City c) => c.province,
                isItemEnabled: (City c) => c.available,
                enableSearch: true,
                showSelectAll: true,
                hintText: 'Pick cities',
                selectedItemsLabel: (List<City> s) =>
                    '${s.length} selected: ${s.map((City c) => c.name).join(', ')}',
                onSelectionChanged: (List<City> list) =>
                    setState(() => _multiCities = list),
              ),

              _section('5. Async load + shimmer skeleton loading'),
              CustomDropdown<City>.async(
                loader: _searchCities,
                value: _asyncCity,
                itemLabel: (City c) => c.name,
                searchHint: 'Type to search cities…',
                hintText: 'Search remotely',
                loading: const DropdownLoading.shimmer(itemCount: 5),
                onChanged: (City c) => setState(() => _asyncCity = c),
              ),

              _section('6. Opens to the RIGHT'),
              CustomDropdown<City>(
                items: kCities,
                value: _sideCity,
                itemLabel: (City c) => c.name,
                direction: DropdownDirection.right,
                menuWidth: 200,
                leading: const Icon(Icons.place_outlined, size: 18),
                hintText: 'Side menu',
                onChanged: (City c) => setState(() => _sideCity = c),
              ),

              _section('7. Disabled dropdown'),
              const CustomDropdown<String>(
                items: <String>['X', 'Y'],
                enabled: false,
                hintText: 'Disabled',
                onChanged: _noop,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _noop(String _) {}

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );
}
