import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo app builds and shows its dropdowns', (tester) async {
    await tester.pumpWidget(const DemoApp());

    expect(find.text('Pick a fruit'), findsOneWidget);
    expect(find.text('Pick a city'), findsOneWidget);
  });
}
