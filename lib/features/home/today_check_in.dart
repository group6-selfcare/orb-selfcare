import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the user has checked in today, as Home sees it.
///
/// For now this is always false: the check-in storage (CheckInRepository,
/// PMG6-50) isn't built yet, so Home always shows its before-check-in state.
///
/// When PMG6-50 lands, replace the body with a read of today's check-in
/// from the repository's provider. Home only depends on this provider, so
/// nothing in Home has to change.
final hasCheckedInTodayProvider = FutureProvider<bool>((ref) async => false);
