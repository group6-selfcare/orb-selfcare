import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/theme/tokens.dart';

void main() {
  testWidgets('OrbApp starts with the Orb theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OrbApp()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, OrbColors.primary);
    expect(find.text('Orb'), findsOneWidget);
  });
}
