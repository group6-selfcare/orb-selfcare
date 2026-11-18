import 'package:flutter/foundation.dart';
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
import '../check_in/mood_level.dart';
import '../onboarding/onboarding_draft.dart';
import '../onboarding/onboarding_routes.dart';

/// The route of the daily check-in.
const checkInPath = '/check-in';

/// The custom Check in icon: a smiling face in a speech bubble.
const checkInIcon = 'assets/svg/icons/check_in.svg';

/// The Home tab: where the pig lives.
///
/// Before today's check-in (PMG6-63) the pig stands curious in its hero
/// area and invites one: the Check in button is filled and the Today card
/// is empty.
///
/// After it (PMG6-64) the pig takes the pose for today's level, greets the
/// user in its trait's voice, and the Today card shows the check-in. The
/// button turns into a quieter Edit, and both open the check-in to edit.
///
/// Home follows `todayCheckInProvider`, so it updates as soon as a check-in
/// is saved or edited. The provider moves to the new day at midnight and
/// on app resume, so after midnight Home falls back to its before-check-in
/// state.
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
    final today = ref.watch(todayCheckInProvider).value;
    final pose = PigPose.forLevel(today?.level);
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
            _Header(checkedIn: today != null, onCheckIn: openCheckIn),
            const SizedBox(height: OrbSpacing.lg),
            _Hero(pigName: profile.pigName, pose: pose),
            const SizedBox(height: OrbSpacing.md),
            _Greeting(
              text: HomeCopy.greetingFor(
                trait: profile.trait ?? Trait.gentle,
                level: today?.level,
                userName: profile.userName,
                pigName: profile.pigName,
              ),
            ),
            const SizedBox(height: OrbSpacing.xl),
            _TodayLabel(),
            const SizedBox(height: OrbSpacing.sm),
            if (today == null)
              _EmptyTodayCard(onTap: openCheckIn)
            else
              _TodayCard(checkIn: today, onTap: openCheckIn),
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

/// "Orb" on the left, the round Check in button (icon only) on the right.
class _Header extends StatelessWidget {
  const _Header({required this.checkedIn, required this.onCheckIn});

  /// Before today's check-in the button is filled and inviting. After it,
  /// it's a quieter outlined Edit.
  final bool checkedIn;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Icon only: the tooltip gives screen readers and long-press the label.
    final icon = SvgPicture.asset(
      checkInIcon,
      width: 28,
      height: 28,
      excludeFromSemantics: true,
    );
    const size = Size.square(48);
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
        if (!checkedIn)
          IconButton.filled(
            key: const ValueKey('home-check-in-pill'),
            onPressed: onCheckIn,
            tooltip: HomeCopy.checkIn,
            style: IconButton.styleFrom(
              backgroundColor: OrbColors.primary,
              fixedSize: size,
            ),
            icon: icon,
          )
        else
          IconButton.outlined(
            key: const ValueKey('home-check-in-pill'),
            onPressed: onCheckIn,
            tooltip: HomeCopy.editCheckIn,
            style: IconButton.styleFrom(
              side: const BorderSide(color: OrbColors.border),
              foregroundColor: OrbColors.primary,
              fixedSize: size,
            ),
            icon: const Icon(Icons.edit_outlined, size: 22),
          ),
      ],
    );
  }
}

/// The pig standing in its soft hero area, with its name on a small tag.
///
/// A plain mist background for now; the province scene comes later.
class _Hero extends StatelessWidget {
  const _Hero({required this.pigName, required this.pose});

  final String pigName;

  /// Curious before today's check-in, then the pose for today's level.
  final PigPose pose;

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: SvgPicture.asset(
              pose.asset,
              key: ValueKey(pose),
              width: 184,
              height: 184,
              semanticsLabel: HomeCopy.pigSemantics(pigName, pose),
            ),
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
    return _TodayCardFrame(
      onTap: onTap,
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
          const Icon(Icons.chevron_right_rounded, color: OrbColors.textMuted),
        ],
      ),
    );
  }
}

/// The tappable surface both Today cards sit on.
class _TodayCardFrame extends StatelessWidget {
  const _TodayCardFrame({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
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
          child: child,
        ),
      ),
    );
  }
}

/// "Today", above the Today card.
class _TodayLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: OrbSpacing.xs),
      child: Text(
        HomeCopy.todayLabel,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: OrbColors.textSecondary),
      ),
    );
  }
}

/// Today's check-in: the level face and label, the emotion, the note (two
/// lines at most) and the tags. Tapping it opens the check-in to edit.
class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.checkIn, required this.onTap});

  final CheckIn checkIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final level = MoodLevel.fromValue(checkIn.level);
    final emotion = moodFromName(checkIn.emotion);
    final note = checkIn.note;
    // tagsProvider is in display order, so the chips match the check-in's.
    final tags = [
      for (final tag in ref.watch(tagsProvider).value ?? const <Tag>[])
        if (checkIn.tagIds.contains(tag.id)) tag.label,
    ];
    // The first save of the day, so an edit doesn't move it.
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(checkIn.createdAt));

    return _TodayCardFrame(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(OrbSpacing.xs),
                decoration: BoxDecoration(
                  color: level.face.color.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  levelFaceAsset(level),
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: OrbSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CheckInCopy.levelSemantics(level),
                      key: const ValueKey('home-today-level'),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HomeCopy.todayCheckedInAt(time),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, color: OrbColors.textMuted),
            ],
          ),
          if (emotion != null) ...[
            const SizedBox(height: OrbSpacing.md),
            Row(
              key: const ValueKey('home-today-emotion'),
              children: [
                SvgPicture.asset(
                  moodFaceAsset(emotion),
                  width: 24,
                  height: 24,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: OrbSpacing.sm),
                Text(
                  CheckInCopy.emotionName[emotion]!,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: OrbSpacing.sm),
            Text(
              note,
              key: const ValueKey('home-today-note'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(color: OrbColors.textSecondary),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: OrbSpacing.md),
            Wrap(
              spacing: OrbSpacing.xs,
              runSpacing: OrbSpacing.xs,
              children: [
                for (final label in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OrbSpacing.md,
                      vertical: OrbSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: OrbColors.mist,
                      borderRadius: BorderRadius.circular(OrbRadii.pill),
                    ),
                    child: Text(label, style: text.labelMedium),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
