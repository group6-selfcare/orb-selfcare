import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';

/// The Home tab.
///
/// A placeholder until Home before and after check-in (PMG6-63, 64) lands.
/// It already links to the check-in route so the shell can be tried out.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Orb')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OrbSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hi there', style: text.headlineMedium),
              const SizedBox(height: OrbSpacing.sm),
              Text(
                'How are you feeling today?',
                style: text.bodyLarge?.copyWith(color: OrbColors.textSecondary),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/check-in'),
                child: const Text('Check in'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: OrbSpacing.sm),
                TextButton(
                  onPressed: () => context.push('/theme-preview'),
                  child: const Text('Theme preview'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
