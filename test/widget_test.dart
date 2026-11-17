import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/orb_app.dart';

void main() {
  testWidgets('OrbApp starts inside a ProviderScope', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OrbApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
