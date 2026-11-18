import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/profile/profile.dart';
import '../../data/profile/profile_repository.dart';
import '../../shared/copy.dart';
import 'onboarding_draft.dart';
import 'onboarding_routes.dart';
import 'onboarding_scaffold.dart';
import 'pig_names.dart';

/// N4 Your name, the last onboarding step.
///
/// The pig introduces itself by the name the user just gave it, then asks
/// for theirs. Next saves all the answers to the device (PMG6-57) and goes
/// to the first check-in. Onboarding is only marked done later, on N15.
class YouScreen extends ConsumerStatefulWidget {
  const YouScreen({super.key});

  @override
  ConsumerState<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends ConsumerState<YouScreen> {
  late final TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Coming back to this step shows what the user typed before.
    _name = TextEditingController(
      text: ref.read(onboardingDraftProvider).userName,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(onboardingDraftProvider.notifier).setUserName(value.trim());
    setState(() {}); // Enables or disables Next.
  }

  Future<void> _next() async {
    final userName = validName(_name.text);
    if (userName == null || _saving) return;
    setState(() => _saving = true);

    final draftNotifier = ref.read(onboardingDraftProvider.notifier);
    draftNotifier.setUserName(userName);
    final draft = ref.read(onboardingDraftProvider);
    try {
      await ref
          .read(profileProvider.notifier)
          .saveAnswers(
            userName: userName,
            pigName: validName(draft.pigName) ?? OnboardingCopy.pigNames.first,
            trait: draft.trait ?? Trait.gentle,
          );
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(OnboardingCopy.saveFailed)),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    context.push(OnboardingRoutes.firstCheckIn);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pigName = ref.watch(onboardingDraftProvider.select((d) => d.pigName));
    final canContinue = validName(_name.text) != null && !_saving;

    return OnboardingScaffold(
      step: 4,
      buttonLabel: OnboardingCopy.next,
      onPressed: canContinue ? _next : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: OrbSpacing.lg),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/svg/pig/pig_curious.svg',
              width: 120,
              height: 120,
              semanticsLabel: 'Your pig companion, curious',
            ),
            const SizedBox(height: OrbSpacing.lg),
            if (pigName.isNotEmpty) ...[
              Text(
                OnboardingCopy.youIntro(pigName),
                style: text.bodyLarge?.copyWith(color: OrbColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OrbSpacing.xs),
            ],
            Text(
              OnboardingCopy.youTitle,
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OrbSpacing.xl),
            TextField(
              key: const ValueKey('user-name-field'),
              controller: _name,
              autofocus: true,
              onChanged: _onChanged,
              onSubmitted: (_) => _next(),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.givenName],
              style: text.headlineMedium,
              inputFormatters: [
                LengthLimitingTextInputFormatter(OnboardingCopy.nameMaxLength),
              ],
              decoration: InputDecoration(
                hintText: OnboardingCopy.youHint,
                hintStyle: text.titleMedium?.copyWith(
                  color: OrbColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: OrbSpacing.lg,
                  vertical: OrbSpacing.lg,
                ),
              ),
            ),
            const SizedBox(height: OrbSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: OrbColors.textSecondary,
                ),
                const SizedBox(width: OrbSpacing.xs),
                Flexible(
                  child: Text(
                    OnboardingCopy.youHelper,
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
