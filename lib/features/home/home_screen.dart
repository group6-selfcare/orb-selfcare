import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/profile/profile.dart';
import '../../data/profile/profile_repository.dart';
import '../../shared/copy.dart';
import '../onboarding/onboarding_draft.dart';
import '../onboarding/onboarding_routes.dart';
import 'today_check_in.dart';

/// The route of the daily check-in.
const checkInPath = '/check-in';

/// The custom Check in icon: a smiling face in a speech bubble.
const checkInIcon = 'assets/svg/icons/check_in.svg';

/// The Home tab: where the pig lives.
///
/// Before today's check-in (PMG6-63) the pig stands in its hero area and
/// invites one: the Check in pill is filled and the Today card is empty.
/// Both open the check-in. Home after check-in is PMG6-64.
///
/// Debug builds also get tools for testing: the theme preview, and a reset
/// that starts onboarding again as if the app was just installed.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    await ref.read(profileProvider.notifier).reset();
    ref.invalidate(onboardingDraftProvider);
    if (context.mounted) context.go(OnboardingRoutes.meet);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value ?? Profile.empty;
    final checkedIn = ref.watch(hasCheckedInTodayProvider).value ?? false;
    void openCheckIn() => context.push(checkInPath);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            OrbSpacing.screen,
            OrbSpacing.md,
            OrbSpacing.screen,
            OrbSpacing.xl,
          ),
          children: [
            _Header(emphasised: !checkedIn, onCheckIn: openCheckIn),
            const SizedBox(height: OrbSpacing.lg),
            _Hero(pigName: profile.pigName),
            const SizedBox(height: OrbSpacing.md),
            _Greeting(
              text: HomeCopy.greetingBefore(
                trait: profile.trait ?? Trait.gentle,
                userName: profile.userName,
                pigName: profile.pigName,
              ),
            ),
            if (!checkedIn) ...[
              const SizedBox(height: OrbSpacing.xl),
              _EmptyTodayCard(onTap: openCheckIn),
            ],
            if (kDebugMode) ...[
              const SizedBox(height: OrbSpacing.xxl),
              TextButton(
                onPressed: () => context.push('/theme-preview'),
                child: const Text('Theme preview'),
              ),
              TextButton(
                onPressed: () => _resetOnboarding(context, ref),
                child: const Text('Reset onboarding (debug)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Orb" on the left, the Check in pill on the right.
class _Header extends StatelessWidget {
  const _Header({required this.emphasised, required this.onCheckIn});

  /// Filled while there's no check-in today, outlined after.
  final bool emphasised;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const label = Text(HomeCopy.checkIn);
    final icon = SvgPicture.asset(
      checkInIcon,
      width: 22,
      height: 22,
      excludeFromSemantics: true,
    );
    final style = ButtonStyle(
      visualDensity: VisualDensity.compact,
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: OrbSpacing.lg),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
    );
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              HomeCopy.title,
              style: text.headlineMedium?.copyWith(color: OrbColors.ink),
            ),
          ),
        ),
        if (emphasised)
          FilledButton.icon(
            key: const ValueKey('home-check-in-pill'),
            onPressed: onCheckIn,
            style: style,
            icon: icon,
            label: label,
          )
        else
          OutlinedButton.icon(
            key: const ValueKey('home-check-in-pill'),
            onPressed: onCheckIn,
            style: style,
            icon: icon,
            label: label,
          ),
      ],
    );
  }
}

/// The pig standing in its soft hero area, with its name on a small tag.
///
/// A plain mist background for now; the province scene comes later.
class _Hero extends StatelessWidget {
  const _Hero({required this.pigName});

  final String pigName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OrbRadii.xl),
        gradient: const RadialGradient(
          center: Alignment(0, 0.15),
          radius: 0.9,
          colors: [OrbColors.surface, OrbColors.mist],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/pig/pig_curious.svg',
            width: 184,
            height: 184,
            semanticsLabel: '$pigName, your pig companion, waiting for you',
          ),
          if (pigName.isNotEmpty)
            Positioned(
              left: OrbSpacing.lg,
              top: OrbSpacing.lg,
              child: _NameTag(name: pigName),
            ),
        ],
      ),
    );
  }
}

class _NameTag extends StatelessWidget {
  const _NameTag({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OrbSpacing.md,
          vertical: OrbSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: OrbColors.surface,
          borderRadius: BorderRadius.circular(OrbRadii.pill),
          border: Border.all(color: OrbColors.border),
        ),
        child: Text(
          name,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: OrbColors.ink),
        ),
      ),
    );
  }
}

/// What the pig says, as a speech bubble pointing up at it.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.text});

  final String text;

  static const _notch = 10.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(_notch * 2, _notch),
          painter: _NotchPainter(),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(OrbSpacing.lg),
          decoration: BoxDecoration(
            color: OrbColors.surface,
            borderRadius: BorderRadius.circular(OrbRadii.lg),
          ),
          child: Text(
            text,
            key: const ValueKey('home-greeting'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: OrbColors.ink, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = OrbColors.surface);
  }

  @override
  bool shouldRepaint(_NotchPainter oldDelegate) => false;
}

/// The Today card when there's no check-in yet. Tapping it opens the
/// check-in.
class _EmptyTodayCard extends StatelessWidget {
  const _EmptyTodayCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: OrbSpacing.xs),
          child: Text(
            HomeCopy.todayLabel,
            style: text.titleSmall?.copyWith(color: OrbColors.textSecondary),
          ),
        ),
        const SizedBox(height: OrbSpacing.sm),
        Material(
          color: OrbColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OrbRadii.lg),
            side: const BorderSide(color: OrbColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('home-today-card'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(OrbSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: OrbColors.mist,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wb_sunny_outlined,
                      color: OrbColors.primary,
                    ),
                  ),
                  const SizedBox(width: OrbSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(HomeCopy.todayEmptyTitle, style: text.titleMedium),
                        const SizedBox(height: OrbSpacing.xs),
                        Text(
                          HomeCopy.todayEmptyBody,
                          style: text.bodyMedium?.copyWith(
                            color: OrbColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: OrbColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
