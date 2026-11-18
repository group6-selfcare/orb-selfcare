import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/check_in/check_in_repository.dart';
import '../../data/profile/profile.dart';
import '../../data/profile/profile_repository.dart';
import '../../shared/copy.dart';
import '../../shared/pig_pose.dart';

/// N15 Day one done: the pig cheers the first check-in.
///
/// "Go to Home" is the only place onboarding is marked done. It then
/// replaces the whole stack with Home, so back can't return to onboarding.
/// The weekly dots from Figma are left out: weekly targets come later.
///
/// The pig's line needs the user's name, the trait and today's level. The
/// line only appears once all three are known, so it never shows an empty
/// name or the wrong voice first.
class DayOneScreen extends ConsumerStatefulWidget {
  const DayOneScreen({super.key, this.level});

  /// Today's level (1 to 5), passed by the first check-in. When it's
  /// missing (for example after a deep link), today's check-in is read
  /// instead.
  final int? level;

  @override
  ConsumerState<DayOneScreen> createState() => _DayOneScreenState();
}

class _DayOneScreenState extends ConsumerState<DayOneScreen> {
  bool _finishing = false;

  Future<void> _goHome() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await ref.read(profileProvider.notifier).completeOnboarding();
    } catch (_) {
      if (mounted) {
        setState(() => _finishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(OnboardingCopy.saveFailed)),
        );
      }
      return;
    }
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider).value;
    final level = widget.level ?? ref.watch(todayCheckInProvider).value?.level;
    final line = (profile == null || level == null)
        ? null
        : OnboardingCopy.dayOneLine(
            trait: profile.trait ?? Trait.gentle,
            level: level,
            userName: profile.userName,
          );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            OrbSpacing.screen,
            OrbSpacing.sm,
            OrbSpacing.screen,
            OrbSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [OrbColors.mist, OrbColors.background],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            PigPose.cheering.asset,
                            width: 160,
                            height: 160,
                            semanticsLabel: 'Your pig companion, cheering',
                          ),
                        ),
                        const SizedBox(height: OrbSpacing.xl),
                        Semantics(
                          header: true,
                          child: Text(
                            OnboardingCopy.dayOneTitle,
                            style: text.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: OrbSpacing.md),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: line == null
                              ? const SizedBox.shrink()
                              : Text(
                                  line,
                                  key: const ValueKey('day-one-line'),
                                  style: text.bodyLarge?.copyWith(
                                    color: OrbColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FilledButton(
                onPressed: _finishing ? null : _goHome,
                child: const Text(OnboardingCopy.dayOneButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
