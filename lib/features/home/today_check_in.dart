import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/check_in/check_in_repository.dart';

/// Whether the user has checked in today, as Home sees it.
///
/// It follows the live today stream, so Home switches to its
/// after-check-in state as soon as a check-in is saved or edited.
final hasCheckedInTodayProvider = FutureProvider<bool>(
  (ref) async => await ref.watch(todayCheckInProvider.future) != null,
);
