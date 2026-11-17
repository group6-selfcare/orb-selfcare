import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/tokens.dart';

/// A friendly placeholder for a tab or route that later sprints will fill in.
///
/// Shows the pig from the Profile tab icon until the Pig D poses are
/// exported (PMG6-51).
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;

  /// An optional button under the message.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OrbSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 144,
                  height: 144,
                  decoration: const BoxDecoration(
                    color: OrbColors.mist,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svg/tabs/tab_profile_active.svg',
                    width: 96,
                    height: 96,
                    semanticsLabel: 'Orb the pig',
                  ),
                ),
                const SizedBox(height: OrbSpacing.xl),
                Text(
                  'Coming soon',
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OrbSpacing.sm),
                Text(
                  message,
                  style: text.bodyLarge?.copyWith(
                    color: OrbColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (action case final action?) ...[
                  const SizedBox(height: OrbSpacing.xl),
                  action,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
