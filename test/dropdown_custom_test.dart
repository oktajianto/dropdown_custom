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

  group('CustomDropdown styling', () {
    testWidgets('fieldStyle.textStyle is applied to the trigger', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple'],
            value: 'Apple',
            fieldStyle: const DropdownFieldStyle(
              textStyle: TextStyle(fontSize: 22),
            ),
            onChanged: (_) {},
          ),
        ),
      );

      final Text trigger = tester.widget<Text>(find.text('Apple'));
      expect(trigger.style?.fontSize, 22);
    });

    testWidgets('menuStyle.itemTextStyle is applied to list rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango'],
            menuStyle: const DropdownMenuStyle(
              itemTextStyle: TextStyle(fontSize: 9),
            ),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      final Text row = tester.widget<Text>(find.text('Apple'));
      expect(row.style?.fontSize, 9);
    });

    testWidgets('searchStyle.hintStyle is applied to the search box', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>(
            items: const <String>['Apple', 'Mango'],
            enableSearch: true,
            searchHint: 'Find',
            searchStyle: const DropdownSearchStyle(
              hintStyle: TextStyle(fontSize: 11),
            ),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.hintStyle?.fontSize, 11);
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

    testWidgets('shimmer loading style renders a skeleton, not a spinner', (
      tester,
    ) async {
      final Completer<List<String>> completer = Completer<List<String>>();
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            loader: (String _) => completer.future,
            loading: const DropdownLoading.shimmer(itemCount: 4),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pump();

      expect(find.byKey(const Key('dropdownLoadingSkeleton')), findsOneWidget);

      completer.complete(<String>['Done']);
      await tester.pumpAndSettle();
    });

    testWidgets('custom loading builder is used', (tester) async {
      final Completer<List<String>> completer = Completer<List<String>>();
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            loader: (String _) => completer.future,
            enableSearch: false,
            loading: DropdownLoading.custom(
              (BuildContext context) => const Text('LOADING…'),
            ),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pump();

      expect(find.text('LOADING…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      completer.complete(<String>['Done']);
      await tester.pumpAndSettle();
    });

    testWidgets('custom emptyBuilder is used when there are no results', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            loader: (String _) async => <String>[],
            emptyBuilder: (BuildContext context) => const Text('Nothing here'),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('custom errorBuilder receives the error and a working retry', (
      tester,
    ) async {
      int calls = 0;
      await tester.pumpWidget(
        _wrap(
          CustomDropdown<String>.async(
            loader: (String _) async {
              calls++;
              if (calls == 1) throw Exception('kaboom');
              return <String>['OK'];
            },
            errorBuilder:
                (BuildContext context, Object error, VoidCallback retry) {
                  return TextButton(
                    onPressed: retry,
                    child: Text('Custom error: $error'),
                  );
                },
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(CustomDropdown<String>));
      await tester.pumpAndSettle();

      expect(find.textContaining('Custom error:'), findsOneWidget);
      expect(find.textContaining('kaboom'), findsOneWidget);

      await tester.tap(find.textContaining('Custom error:'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
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
