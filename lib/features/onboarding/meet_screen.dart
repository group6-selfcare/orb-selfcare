import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../shared/copy.dart';
import 'onboarding_routes.dart';
import 'onboarding_scaffold.dart';

/// N1 Meet your companion: the first screen a new user sees.
///
/// The pig waves from a soft glow, and three short promises say what the
/// app asks of you. The content eases in one piece at a time.
class MeetScreen extends StatelessWidget {
  const MeetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return OnboardingScaffold(
      step: 1,
      showTopBar: false,
      buttonLabel: OnboardingCopy.meetButton,
      footnote: OnboardingCopy.meetFootnote,
      onPressed: () => context.push(OnboardingRoutes.name),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _EaseIn(order: 0, child: _Hero()),
              const SizedBox(height: OrbSpacing.xl),
              _EaseIn(
                order: 1,
                child: Text(
                  OnboardingCopy.meetTitle,
                  style: text.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: OrbSpacing.xl),
              for (final (i, promise) in OnboardingCopy.meetPromises.indexed)
                _EaseIn(
                  order: 2 + i,
                  child: _Promise(icon: _promiseIcons[i], text: promise),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _promiseIcons = [
    Icons.wb_sunny_outlined,
    Icons.explore_outlined,
    Icons.lock_outline,
  ];
}

/// The waving pig on a soft porcelain glow.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [OrbColors.mist, OrbColors.background],
          stops: [0.55, 1],
        ),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/svg/pig/pig_wave.svg',
        width: 156,
        height: 156,
        semanticsLabel: 'Your pig companion, waving hello',
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OrbSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: OrbColors.mist,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: OrbColors.primary),
            ),
            const SizedBox(width: OrbSpacing.md),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades and lifts its child into place, a little after the one before it.
/// Shows it straight away when the phone asks for less motion.
class _EaseIn extends StatelessWidget {
  const _EaseIn({required this.order, required this.child});

  final int order;
  final Widget child;

  static const _step = Duration(milliseconds: 90);
  static const _length = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = _step * order;
    final total = delay + _length;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
