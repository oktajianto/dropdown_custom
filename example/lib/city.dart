/// A simple model to demonstrate that the dropdown works over any type `T`,
/// not just `String`. Shared across the example pages.
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

/// Fake network search used by the async demos: filters [kCities] by [query]
/// after a short delay.
Future<List<City>> searchCities(String query) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  final String q = query.toLowerCase();
  return kCities.where((City c) => c.name.toLowerCase().contains(q)).toList();
}
