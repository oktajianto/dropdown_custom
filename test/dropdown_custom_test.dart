import 'package:dropdown_custom/dropdown_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('CustomDropdown single-select', () {
    testWidgets('shows hint when nothing is selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango'],
            hintText: 'Pick one',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('opens the menu and lists items on tap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango', 'Orange'],
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
    });

    testWidgets('selecting an item fires onChanged with the value', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango'],
            onChanged: (String v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mango'));
      await tester.pumpAndSettle();

      expect(picked, 'Mango');
    });

    testWidgets('search filters the visible items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango', 'Orange'],
            enableSearch: true,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'an');
      await tester.pumpAndSettle();

      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('disabled items do not fire onChanged', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango'],
            isItemEnabled: (String v) => v != 'Mango',
            onChanged: (String v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mango'));
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });

    testWidgets('grouped items render their group headers', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Carrot'],
            groupBy: (String v) => v == 'Apple' ? 'Fruit' : 'Vegetable',
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('Fruit'), findsOneWidget);
      expect(find.text('Vegetable'), findsOneWidget);
    });

    testWidgets('disabled dropdown does not open', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango'],
            enabled: false,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
    });
  });

  group('CustomDropdown multi-select', () {
    testWidgets('shows the hint when nothing is selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.multi(
            items: const <String>['Apple', 'Mango'],
            hintText: 'Pick some',
            onSelectionChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Pick some'), findsOneWidget);
    });

    testWidgets('toggling items reports the full selection and stays open', (
      tester,
    ) async {
      List<String> selection = <String>[];
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.multi(
            items: const <String>['Apple', 'Mango', 'Orange'],
            onSelectionChanged: (List<String> v) => selection = v,
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(selection, <String>['Apple']);

      // Menu is still open, so a second item can be toggled.
      await tester.tap(find.text('Orange'));
      await tester.pumpAndSettle();
      expect(selection, <String>['Apple', 'Orange']);

      // Toggling Apple again removes it.
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(selection, <String>['Orange']);
    });

    testWidgets('pre-selected items render as checked', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.multi(
            items: const <String>['Apple', 'Mango'],
            selectedItems: const <String>['Mango'],
            onSelectionChanged: (_) {},
          ),
        ),
      );

      // Trigger shows the current selection.
      expect(find.text('Mango'), findsOneWidget);

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });
  });
}
