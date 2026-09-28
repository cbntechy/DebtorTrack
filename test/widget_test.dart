// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:debtortrack/models/debtor_model.dart';
import 'package:debtortrack/screens/debtor_list_screen.dart';

void main() {
  test('statuses reflect overdue, today, and future due dates', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final debtors = [
      DebtorModel(
        name: 'Ada Overdue',
        amount: 1500,
        email: 'ada@example.com',
        dueDate: today.subtract(const Duration(days: 1)),
        isPaid: false,
      ),
      DebtorModel(
        name: 'Tobi Today',
        amount: 2500,
        email: 'tobi@example.com',
        dueDate: today,
        isPaid: false,
      ),
      DebtorModel(
        name: 'Femi Future',
        amount: 3500,
        email: 'femi@example.com',
        dueDate: today.add(const Duration(days: 1)),
        isPaid: false,
      ),
    ];

    expect(debtors.map((debtor) => debtor.getStatus()), [
      'Overdue',
      'Due Today',
      'Upcoming',
    ]);
  });

  testWidgets('renders correctly colored chips for each due-date status', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final debtors = [
      DebtorModel(
        name: 'Ada Overdue',
        amount: 1500,
        email: 'ada@example.com',
        dueDate: today.subtract(const Duration(days: 1)),
        isPaid: false,
      ),
      DebtorModel(
        name: 'Tobi Today',
        amount: 2500,
        email: 'tobi@example.com',
        dueDate: today,
        isPaid: false,
      ),
      DebtorModel(
        name: 'Femi Future',
        amount: 3500,
        email: 'femi@example.com',
        dueDate: today.add(const Duration(days: 1)),
        isPaid: false,
      ),
    ];
    SharedPreferences.setMockInitialValues({
      'debtors': jsonEncode(debtors.map((debtor) => debtor.toMap()).toList()),
    });

    await tester.pumpWidget(const MaterialApp(home: DebtorListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Due Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('₦1500.00'), findsOneWidget);
    expect(find.text('Due: ${today.toIso8601String().split('T').first}'), findsOneWidget);

    expect(_chipColor(tester, 'Overdue'), const Color(0xFFFDE8E7));
    expect(_chipColor(tester, 'Due Today'), const Color(0xFFFFF1E0));
    expect(_chipColor(tester, 'Upcoming'), const Color(0xFFEDE7F6));
  });
}

Color? _chipColor(WidgetTester tester, String status) {
  final chip = find.ancestor(
    of: find.text(status),
    matching: find.byType(Container),
  );
  final container = tester.widget<Container>(chip.first);
  return (container.decoration! as BoxDecoration).color;
}
