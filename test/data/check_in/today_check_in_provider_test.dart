import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/data/check_in/check_in_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late DateTime now;
  late ProviderContainer container;

  /// A container whose clock is [now], with a check-in saved at 23:59.
  Future<void> setUpAt2359(WidgetTester tester) async {
    now = DateTime(2026, 11, 18, 23, 59);
    container = ProviderContainer(
      overrides: [
        inMemoryDatabase(),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    // Keep the provider alive, as Home does.
    container.listen(todayCheckInProvider, (_, _) {});
    await container.read(checkInRepositoryProvider).saveToday(level: 2);
    await tester.pump();
    expect(container.read(todayCheckInProvider).value?.day, '2026-11-18');
  }

  /// Lets drift's stream queries and Riverpod settle in fake time.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('refreshes at local midnight', (tester) async {
    await setUpAt2359(tester);

    // The phone stays awake past midnight: the timer fires.
    now = DateTime(2026, 11, 19, 0, 1);
    await tester.pump(const Duration(minutes: 2));
    await settle(tester);
    expect(container.read(todayCheckInProvider).value, isNull);

    now = DateTime(2026, 11, 19, 8);
    await container.read(checkInRepositoryProvider).saveToday(level: 5);
    await settle(tester);
    final today = container.read(todayCheckInProvider).value;
    expect(today?.day, '2026-11-19');
    expect(today?.level, 5);

    container.dispose();
  });

  testWidgets('refreshes when the app comes back to the foreground', (
    tester,
  ) async {
    await setUpAt2359(tester);

    // The phone slept through midnight, so the timer never ran.
    now = DateTime(2026, 11, 19, 8);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);
    expect(container.read(todayCheckInProvider).value, isNull);

    await container.read(checkInRepositoryProvider).saveToday(level: 5);
    await settle(tester);
    expect(container.read(todayCheckInProvider).value?.level, 5);

    container.dispose();
  });
}
