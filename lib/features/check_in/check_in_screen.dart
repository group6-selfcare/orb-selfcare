import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/check_in/check_in_repository.dart';
import '../../shared/copy.dart';
import '../onboarding/onboarding_routes.dart';
import 'mood_level.dart';

/// The daily check-in at `/check-in`.
///
/// One tap on a face is a complete check-in: it's saved straight away, so a
/// student on a hard day can stop there. The optional extras then open
/// below, with a Done button.
///
/// Leaving (Done, the back arrow or Android back) after a face was tapped
/// saves again, so nothing typed is lost. Leaving before saves nothing.
///
/// With [onboarding] it's the user's first check-in (N12, N13): its own
/// title and question, Continue instead of Done, a Skip action once a face
/// is picked, and both go on to N15 Day one done. The check-in saved is a
/// real one for today, exactly as in normal mode.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  // Read once: saving on the way out runs after this widget is gone.
  late final CheckInRepository _repo = ref.read(checkInRepositoryProvider);

  MoodLevel? _level;

  /// The optional, more precise feeling. Only one at a time.
  Mood? _emotion;

  final _note = TextEditingController();
  final _tagIds = <String>{};

  /// True when today already had a check-in: the screen edits it.
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  /// Opens today's check-in for editing, if there is one. A new day (after
  /// local midnight) has none, so the screen starts empty.
  Future<void> _prefill() async {
    final CheckIn? today;
    try {
      today = await _repo.getToday();
    } catch (_) {
      return; // Start empty; saving will report any real problem.
    }
    // Don't overwrite a face the user already tapped while this loaded.
    if (today == null || !mounted || _level != null) return;
    setState(() {
      _editing = true;
      _level = MoodLevel.fromValue(today!.level);
      _emotion = moodFromName(today.emotion);
      _note.text = today.note ?? '';
      _tagIds
        ..clear()
        ..addAll(today.tagIds);
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Saves run one after another, so the last one always wins.
  Future<void> _saving = Future.value();
  bool _leaving = false;

  Future<void> _save() {
    final level = _level;
    if (level == null) return _saving;
    final emotion = _emotion?.name;
    final note = _note.text;
    final tagIds = {..._tagIds};
    return _saving = _saving.then(
      (_) => _repo
          .saveToday(
            level: level.value,
            emotion: emotion,
            note: note,
            tagIds: tagIds,
          )
          .catchError((Object _) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(CheckInCopy.saveFailed)),
              );
            }
          }),
    );
  }

  void _pickLevel(MoodLevel level) {
    setState(() {
      _level = level;
      // Keep the emotion only if the new level still offers it.
      if (!emotionsForLevel[level]!.contains(_emotion)) _emotion = null;
    });
    _save();
  }

  /// Tags are saved with everything else on Done or on the way out.
  void _toggleTag(String id) {
    setState(() => _tagIds.contains(id) ? _tagIds.remove(id) : _tagIds.add(id));
  }

  /// Tapping the picked emotion again clears it.
  void _pickEmotion(Mood emotion) {
    setState(() => _emotion = _emotion == emotion ? null : emotion);
    _save();
  }

  Future<void> _done() async {
    if (_leaving) return;
    _leaving = true;
    await _save();
    if (!mounted) return;
    if (widget.onboarding) {
      // Pushed, not popped: back from N15 returns here, ready to go again.
      _leaving = false;
      context.push(OnboardingRoutes.dayOne);
    } else {
      _close();
    }
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
          title: Text(
            widget.onboarding
                ? CheckInCopy.firstTitle
                : _editing
                ? CheckInCopy.editTitle
                : CheckInCopy.title,
          ),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.chevron_left, size: 28),
            tooltip: OnboardingCopy.back,
          ),
          actions: [
            // The note and tags are optional: Skip goes straight on.
            if (widget.onboarding && level != null)
              TextButton(
                key: const ValueKey('check-in-skip'),
                onPressed: _done,
                child: const Text(CheckInCopy.skip),
              ),
            const SizedBox(width: OrbSpacing.sm),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    OrbSpacing.screen,
                    OrbSpacing.sm,
                    OrbSpacing.screen,
                    OrbSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          widget.onboarding
                              ? CheckInCopy.firstQuestion
                              : CheckInCopy.question,
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
                            : _Extras(
                                level: level,
                                emotion: _emotion,
                                onEmotion: _pickEmotion,
                                note: _note,
                                tagIds: _tagIds,
                                onTag: _toggleTag,
                              ),
                      ),
                    ],
                  ),
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
                    child: Text(
                      widget.onboarding
                          ? CheckInCopy.continueLabel
                          : CheckInCopy.done,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The optional extras, shown once a level is picked: the saved note, then
/// "Want to name it?". The note and tags (PMG6-60) go below.
class _Extras extends StatelessWidget {
  const _Extras({
    required this.level,
    required this.emotion,
    required this.onEmotion,
    required this.note,
    required this.tagIds,
    required this.onTag,
  });

  final MoodLevel level;
  final Mood? emotion;
  final ValueChanged<Mood> onEmotion;
  final TextEditingController note;
  final Set<String> tagIds;
  final ValueChanged<String> onTag;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      key: const ValueKey('check-in-extras'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: OrbSpacing.lg),
        Row(
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
                style: text.bodySmall?.copyWith(color: OrbColors.success),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: OrbSpacing.xl),
        EmotionPicker(level: level, selected: emotion, onPicked: onEmotion),
        const SizedBox(height: OrbSpacing.lg),
        TextField(
          key: const ValueKey('check-in-note'),
          controller: note,
          minLines: 3,
          maxLines: 6,
          maxLength: CheckInCopy.noteMaxLength,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(hintText: CheckInCopy.noteHint),
        ),
        const SizedBox(height: OrbSpacing.sm),
        TagPicker(selected: tagIds, onToggled: onTag),
      ],
    );
  }
}

/// "What's it about?": the 8 primary tags as chips, and all 18 behind
/// "More tags". Several can be picked.
class TagPicker extends ConsumerStatefulWidget {
  const TagPicker({super.key, required this.selected, required this.onToggled});

  final Set<String> selected;
  final ValueChanged<String> onToggled;

  @override
  ConsumerState<TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends ConsumerState<TagPicker> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final shown = [
      for (final tag in tags)
        // A picked tag stays visible even when the list is folded.
        if (_showAll || tag.isPrimary || widget.selected.contains(tag.id)) tag,
    ];

    return Container(
      padding: const EdgeInsets.all(OrbSpacing.lg),
      decoration: BoxDecoration(
        color: OrbColors.surface,
        borderRadius: BorderRadius.circular(OrbRadii.xl),
        border: Border.all(color: OrbColors.border),
      ),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: Text(CheckInCopy.tagsTitle, style: text.titleMedium),
          ),
          const SizedBox(height: OrbSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: OrbSpacing.sm,
            runSpacing: OrbSpacing.sm,
            children: [
              for (final tag in shown)
                FilterChip(
                  key: ValueKey('tag-${tag.id}'),
                  label: Text(tag.label),
                  selected: widget.selected.contains(tag.id),
                  onSelected: (_) => widget.onToggled(tag.id),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
            ],
          ),
          const SizedBox(height: OrbSpacing.xs),
          TextButton.icon(
            key: const ValueKey('more-tags'),
            onPressed: () => setState(() => _showAll = !_showAll),
            iconAlignment: IconAlignment.end,
            icon: Icon(
              _showAll
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
            label: Text(
              _showAll ? CheckInCopy.fewerTags : CheckInCopy.moreTags,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Want to name it?": the faces that match [level]. Optional, one at a
/// time, and tapping the picked one again clears it.
class EmotionPicker extends StatelessWidget {
  const EmotionPicker({
    super.key,
    required this.level,
    required this.selected,
    required this.onPicked,
  });

  final MoodLevel level;
  final Mood? selected;
  final ValueChanged<Mood> onPicked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(OrbSpacing.lg),
      decoration: BoxDecoration(
        color: OrbColors.surface,
        borderRadius: BorderRadius.circular(OrbRadii.xl),
        border: Border.all(color: OrbColors.border),
      ),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: Text(CheckInCopy.emotionTitle, style: text.titleMedium),
          ),
          const SizedBox(height: 2),
          Text(
            CheckInCopy.emotionHint,
            style: text.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OrbSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final mood in emotionsForLevel[level]!)
                Expanded(
                  child: _EmotionFace(
                    mood: mood,
                    selected: mood == selected,
                    onTap: () => onPicked(mood),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmotionFace extends StatelessWidget {
  const _EmotionFace({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final label = CheckInCopy.emotionName[mood]!;
    return Semantics(
      key: ValueKey('emotion-${mood.name}'),
      container: true,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OrbRadii.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: OrbSpacing.xs),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: _duration,
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // The face's own colour, softly, when picked.
                    color: selected
                        ? mood.color.withValues(alpha: 0.35)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected ? OrbColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: SvgPicture.asset(moodFaceAsset(mood)),
                ),
                const SizedBox(height: OrbSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? OrbColors.primary : OrbColors.ink,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
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
