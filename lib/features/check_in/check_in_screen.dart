import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/check_in/check_in_repository.dart';
import '../../shared/copy.dart';
import 'mood_level.dart';

/// The daily check-in at `/check-in`.
///
/// One tap on a face is a complete check-in: it's saved straight away, so a
/// student on a hard day can stop there. The optional extras then open
/// below, with a Done button.
///
/// Leaving (Done, the back arrow or Android back) after a face was tapped
/// saves again, so nothing typed is lost. Leaving before saves nothing.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  // Read once: saving on the way out runs after this widget is gone.
  late final CheckInRepository _repo = ref.read(checkInRepositoryProvider);

  MoodLevel? _level;

  /// Saves run one after another, so the last one always wins.
  Future<void> _saving = Future.value();
  bool _leaving = false;

  Future<void> _save() {
    final level = _level;
    if (level == null) return _saving;
    return _saving = _saving.then(
      (_) => _repo.saveToday(level: level.value).catchError((Object _) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(CheckInCopy.saveFailed)));
        }
      }),
    );
  }

  void _pickLevel(MoodLevel level) {
    setState(() => _level = level);
    _save();
  }

  Future<void> _done() async {
    if (_leaving) return;
    _leaving = true;
    await _save();
    if (!mounted) return;
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final level = _level;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        // The back arrow and Android back keep what was picked.
        if (didPop && !_leaving) _save();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(CheckInCopy.title),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.chevron_left, size: 28),
            tooltip: OnboardingCopy.back,
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    OrbSpacing.screen,
                    OrbSpacing.sm,
                    OrbSpacing.screen,
                    OrbSpacing.xl,
                  ),
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/svg/pig/pig_wave.svg',
                        width: 120,
                        height: 120,
                        semanticsLabel: 'Your pig companion, waving',
                      ),
                    ),
                    const SizedBox(height: OrbSpacing.lg),
                    Semantics(
                      header: true,
                      child: Text(
                        CheckInCopy.question,
                        style: text.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: OrbSpacing.xs),
                    Text(
                      CheckInCopy.reassurance,
                      style: text.bodyMedium?.copyWith(
                        color: OrbColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: OrbSpacing.xl),
                    LevelPicker(selected: level, onPicked: _pickLevel),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: level == null
                          ? const SizedBox(width: double.infinity)
                          : const _Extras(),
                    ),
                  ],
                ),
              ),
              if (level != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OrbSpacing.screen,
                    0,
                    OrbSpacing.screen,
                    OrbSpacing.xl,
                  ),
                  child: FilledButton(
                    key: const ValueKey('check-in-done'),
                    onPressed: _done,
                    child: const Text(CheckInCopy.done),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The optional extras, shown once a level is picked. The emotion, note
/// and tags (PMG6-59, 60) go here.
class _Extras extends StatelessWidget {
  const _Extras();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('check-in-extras'),
      padding: const EdgeInsets.only(top: OrbSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: OrbColors.success,
          ),
          const SizedBox(width: OrbSpacing.xs),
          Flexible(
            child: Text(
              CheckInCopy.saved,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: OrbColors.success),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// The five faces, Rough to Great. Picking one highlights it and quietens
/// the others.
class LevelPicker extends StatelessWidget {
  const LevelPicker({
    super.key,
    required this.selected,
    required this.onPicked,
  });

  final MoodLevel? selected;
  final ValueChanged<MoodLevel> onPicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final level in MoodLevel.values)
          Expanded(
            child: _LevelFace(
              level: level,
              selected: level == selected,
              quiet: selected != null && level != selected,
              onTap: () => onPicked(level),
            ),
          ),
      ],
    );
  }
}

class _LevelFace extends StatelessWidget {
  const _LevelFace({
    required this.level,
    required this.selected,
    required this.quiet,
    required this.onTap,
  });

  final MoodLevel level;
  final bool selected;

  /// Another face is picked, so this one steps back.
  final bool quiet;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final label = CheckInCopy.levelName[level]!;

    return Semantics(
      key: ValueKey('level-${level.name}'),
      container: true,
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: CheckInCopy.levelSemantics(level),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OrbRadii.lg),
        child: ConstrainedBox(
          // At least 48dp each way, as Android asks.
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: OrbSpacing.xs),
            child: AnimatedOpacity(
              duration: _duration,
              opacity: quiet ? 0.45 : 1,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: _duration,
                    curve: Curves.easeOut,
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? OrbColors.mist : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? OrbColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: AnimatedScale(
                      duration: _duration,
                      scale: selected ? 1.08 : 1,
                      child: SvgPicture.asset(moodFaceAsset(level.face)),
                    ),
                  ),
                  const SizedBox(height: OrbSpacing.xs),
                  Text(
                    label,
                    style: text.labelMedium?.copyWith(
                      color: selected ? OrbColors.primary : OrbColors.ink,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
