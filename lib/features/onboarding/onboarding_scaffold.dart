import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../shared/copy.dart';

/// The layout every onboarding step (N1 to N4) shares: a top bar with a
/// back arrow and the progress bar, the step's content, and one primary
/// button at the bottom.
///
/// N1 is a clean welcome in Figma, so it passes `showTopBar: false`.
/// Android back is left to the navigator: on N1 it closes the app, and on
/// later steps it goes back one step.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.buttonLabel,
    required this.onPressed,
    required this.child,
    this.showTopBar = true,
    this.footnote,
  });

  /// The number of onboarding steps shown in the progress bar.
  static const totalSteps = 4;

  /// This screen's step, from 1 (N1) to [totalSteps] (N4).
  final int step;
  final String buttonLabel;

  /// Null disables the button, e.g. while a required field is empty.
  final VoidCallback? onPressed;
  final Widget child;
  final bool showTopBar;

  /// An optional quiet line under the button.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
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
              if (showTopBar) _TopBar(step: step),
              Expanded(child: child),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
              if (footnote case final footnote?) ...[
                const SizedBox(height: OrbSpacing.md),
                Text(
                  footnote,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.chevron_left, size: 28),
            color: OrbColors.ink,
            tooltip: OnboardingCopy.back,
            // Line the chevron up with the content edge, as in Figma.
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(width: OrbSpacing.xs),
          Expanded(
            child: OnboardingProgress(
              step: step,
              total: OnboardingScaffold.totalSteps,
            ),
          ),
          // Balances the back button so the bar sits in the middle.
          const SizedBox(width: 48 + OrbSpacing.xs),
        ],
      ),
    );
  }
}

/// A rounded track that fills up step by step, with the pig's head riding
/// the end of the fill.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.step,
    required this.total,
  });

  final int step;
  final int total;

  static const _trackHeight = 12.0;
  static const _headWidth = 21.0;
  static const _headHeight = 18.375;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: OnboardingCopy.progress(step, total),
      excludeSemantics: true,
      child: SizedBox(
        height: _headHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fill = constraints.maxWidth * (step / total);
            final headLeft = (fill - _headWidth / 2).clamp(
              0.0,
              constraints.maxWidth - _headWidth,
            );
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: OrbColors.border,
                    borderRadius: BorderRadius.circular(OrbRadii.pill),
                  ),
                ),
                Container(
                  key: const ValueKey('onboarding-progress-fill'),
                  width: fill,
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: OrbColors.primary,
                    borderRadius: BorderRadius.circular(OrbRadii.pill),
                  ),
                ),
                Positioned(
                  left: headLeft,
                  child: SvgPicture.asset(
                    'assets/svg/pig/pig_head.svg',
                    width: _headWidth,
                    height: _headHeight,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
