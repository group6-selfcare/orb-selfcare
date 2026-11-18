import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/profile/profile.dart';
import '../../shared/copy.dart';
import 'onboarding_draft.dart';
import 'onboarding_routes.dart';
import 'onboarding_scaffold.dart';

/// N3 Companion trait: pick the pig's voice for good days.
///
/// Three cards work like radio buttons. Gentle is picked to begin with, and
/// a choice made earlier is shown again when the user comes back.
class TraitScreen extends ConsumerWidget {
  const TraitScreen({super.key});

  static const _icons = {
    Trait.gentle: Icons.spa_outlined,
    Trait.cheerful: Icons.wb_sunny_outlined,
    Trait.playful: Icons.celebration_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final selected = ref.watch(
      onboardingDraftProvider.select((d) => d.trait ?? Trait.gentle),
    );
    final draft = ref.read(onboardingDraftProvider.notifier);

    return OnboardingScaffold(
      step: 3,
      buttonLabel: OnboardingCopy.next,
      onPressed: () {
        // Store it even if the user kept the preselected Gentle.
        draft.setTrait(selected);
        context.push(OnboardingRoutes.you);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: OrbSpacing.lg),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/svg/pig/pig_cheer.svg',
              width: 112,
              height: 112,
              semanticsLabel: 'Your pig companion, cheering',
            ),
            const SizedBox(height: OrbSpacing.lg),
            Text(
              OnboardingCopy.traitTitle,
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OrbSpacing.sm),
            Text(
              OnboardingCopy.traitSubtitle,
              style: text.bodyMedium?.copyWith(color: OrbColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OrbSpacing.xl),
            for (final trait in Trait.values) ...[
              _TraitCard(
                trait: trait,
                icon: _icons[trait]!,
                selected: trait == selected,
                onTap: () => draft.setTrait(trait),
              ),
              const SizedBox(height: OrbSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _TraitCard extends StatelessWidget {
  const _TraitCard({
    required this.trait,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final Trait trait;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = OnboardingCopy.traitName[trait]!;
    final description = OnboardingCopy.traitDescription[trait]!;
    final sample = OnboardingCopy.traitSample[trait]!;
    final radius = BorderRadius.circular(OrbRadii.xl);

    // One node for TalkBack: "Gentle, Calm and soft…, selected, in group".
    return Semantics(
      key: ValueKey('trait-${trait.name}'),
      container: true,
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: '$name. $description. $sample',
      excludeSemantics: true,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? OrbColors.mist : OrbColors.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? OrbColors.primary : OrbColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(OrbSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? OrbColors.surface : OrbColors.mist,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: OrbColors.primary),
                  ),
                  const SizedBox(width: OrbSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: text.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: text.bodyMedium?.copyWith(
                            color: OrbColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: OrbSpacing.xs),
                        Text(
                          sample,
                          style: text.bodyMedium?.copyWith(
                            color: OrbColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: OrbSpacing.sm),
                  _RadioDot(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? OrbColors.primary : OrbColors.surface,
        border: Border.all(
          color: selected ? OrbColors.primary : OrbColors.soft,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: OrbColors.surface)
          : null,
    );
  }
}
