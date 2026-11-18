import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../shared/copy.dart';
import 'onboarding_draft.dart';
import 'onboarding_routes.dart';
import 'onboarding_scaffold.dart';
import 'pig_names.dart';

/// N2 Name your companion.
///
/// The name is the hero: it sits large in the middle of the screen,
/// pre-filled with a suggestion, with a shuffle button right under it.
/// The content scrolls, so with the keyboard open the field and Next stay
/// in view even on a small phone.
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    // Coming back to this step shows what the user typed before.
    final saved = ref.read(onboardingDraftProvider).pigName;
    _name = TextEditingController(
      text: saved.isNotEmpty ? saved : OnboardingCopy.pigNames.first,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(onboardingDraftProvider.notifier).setPigName(value.trim());
    setState(() {}); // Enables or disables Next.
  }

  void _suggest() {
    final name = suggestPigName(_name.text);
    _name.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
    _onChanged(name);
  }

  void _next() {
    final name = validName(_name.text);
    if (name == null) return;
    ref.read(onboardingDraftProvider.notifier).setPigName(name);
    context.push(OnboardingRoutes.trait);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final canContinue = validName(_name.text) != null;

    return OnboardingScaffold(
      step: 2,
      buttonLabel: OnboardingCopy.next,
      onPressed: canContinue ? _next : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: OrbSpacing.lg),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/svg/pig/pig_wave.svg',
              width: 120,
              height: 120,
              semanticsLabel: 'Your pig companion',
            ),
            const SizedBox(height: OrbSpacing.lg),
            Text(
              OnboardingCopy.nameTitle,
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OrbSpacing.xl),
            TextField(
              key: const ValueKey('pig-name-field'),
              controller: _name,
              onChanged: _onChanged,
              onSubmitted: (_) => _next(),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: text.headlineMedium,
              inputFormatters: [
                LengthLimitingTextInputFormatter(OnboardingCopy.nameMaxLength),
              ],
              decoration: const InputDecoration(
                hintText: OnboardingCopy.nameHint,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: OrbSpacing.lg,
                  vertical: OrbSpacing.lg,
                ),
              ),
            ),
            const SizedBox(height: OrbSpacing.md),
            TextButton.icon(
              onPressed: _suggest,
              icon: const Icon(Icons.shuffle, size: 20),
              label: const Text(OnboardingCopy.nameSuggest),
            ),
            const SizedBox(height: OrbSpacing.xs),
            Text(
              OnboardingCopy.nameHelper,
              style: text.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
