import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/orb_app.dart';
import 'package:orb_pm/app/router.dart';
import 'package:orb_pm/app/theme/theme_preview_screen.dart';

import '../../helpers/test_database.dart';

void main() {
  testWidgets('lists do not stretch or glow when pulled past the edge', (
    tester,
  ) async {
    final router = createRouter(initialLocation: '/theme-preview');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          overrideDatabase(),
        ],
        child: const OrbApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ThemePreviewScreen), findsOneWidget);

    // Pull down at the top of the list.
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsNothing);

    await tester.pumpAndSettle();
  });
}
