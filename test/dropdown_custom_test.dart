import 'dart:async';

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

    testWidgets('select-all row is hidden by default', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.multi(
            items: const <String>['Apple', 'Mango'],
            onSelectionChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('Select all'), findsNothing);
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('select all picks enabled items and skips disabled ones', (
      tester,
    ) async {
      List<String> selection = <String>[];
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.multi(
            items: const <String>['Apple', 'Mango', 'Orange'],
            isItemEnabled: (String v) => v != 'Mango',
            showSelectAll: true,
            onSelectionChanged: (List<String> v) => selection = v,
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(selection, <String>['Apple', 'Orange']);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(selection, isEmpty);
    });

    testWidgets('select all respects the active search filter', (tester) async {
      List<String> selection = <String>[];
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.multi(
            items: const <String>['Apple', 'Mango', 'Orange'],
            enableSearch: true,
            showSelectAll: true,
            onSelectionChanged: (List<String> v) => selection = v,
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'an');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      // Only the filtered items ("Mango", "Orange") are selected.
      expect(selection, <String>['Mango', 'Orange']);
    });
  });

  group('CustomDropdown async', () {
    testWidgets('shows a spinner then the loaded items', (tester) async {
      final Completer<List<String>> completer = Completer<List<String>>();
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            loader: (String _) => completer.future,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pump(); // open + kick off the initial load

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      completer.complete(<String>['Ada', 'Bob']);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows an error state with retry that reloads', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            loader: (String _) async {
              calls++;
              if (calls == 1) throw Exception('boom');
              return <String>['Recovered'];
            },
            errorText: 'Oops',
            retryText: 'Try again',
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('Oops'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Recovered'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('debounces loader calls while typing', (tester) async {
      final List<String> queries = <String>[];
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            debounce: const Duration(milliseconds: 300),
            loader: (String q) async {
              queries.add(q);
              return <String>[q];
            },
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle(); // initial load with empty query

      // Three quick keystrokes within the debounce window.
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'abc');

      // Fire the debounce timer, then let the load complete.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Initial '' plus a single debounced 'abc' — not one call per keystroke.
      expect(queries, <String>['', 'abc']);
    });
  });
}
