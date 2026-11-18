import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_database.dart';

void main() {
  testWidgets('OrbApp starts with the Orb theme', (tester) async {
    SharedPreferences.setMockInitialValues({'profile.onboardingDone': true});
    await tester.pumpWidget(
      ProviderScope(overrides: [overrideDatabase()], child: const OrbApp()),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, OrbColors.primary);
    expect(find.text('Orb'), findsOneWidget);
  });
}
