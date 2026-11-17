import 'package:flutter/material.dart';

import 'tokens.dart';

/// A sample screen that shows the theme's colours, type and components.
///
/// It's the app's temporary start screen until the tab shell (PMG6-47)
/// replaces it, so the designer can check the palette on a phone (PMG6-46).
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  final _selectedTags = <String>{'Friends'};
  int _tab = 0;

  static const _tags = ['Work', 'Education', 'Family', 'Friends', 'Health'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orb'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: OrbSpacing.screen),
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: OrbSpacing.lg),
              ),
              child: const Text('Check in'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(OrbSpacing.screen),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: OrbColors.mist,
              borderRadius: BorderRadius.circular(OrbRadii.xl),
            ),
            alignment: Alignment.center,
            child: Text('Pig D goes here', style: text.bodySmall),
          ),
          const SizedBox(height: OrbSpacing.lg),
          Text('Good morning, Dara', style: text.headlineSmall),
          const SizedBox(height: OrbSpacing.xs),
          Text(
            'Bao saved you a quiet spot today. How are you feeling?',
            style: text.bodyLarge,
          ),
          const SizedBox(height: OrbSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OrbSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Today', style: text.bodySmall),
                      const Spacer(),
                      Text(
                        'Day one, done',
                        style: text.labelSmall?.copyWith(
                          color: OrbColors.champagneInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: OrbSpacing.sm),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: OrbColors.champagne,
                      ),
                      const SizedBox(width: OrbSpacing.sm),
                      Text('Feeling good', style: text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: OrbSpacing.md),
                  Wrap(
                    spacing: OrbSpacing.sm,
                    runSpacing: OrbSpacing.sm,
                    children: [
                      for (final tag in _tags)
                        FilterChip(
                          label: Text(tag),
                          selected: _selectedTags.contains(tag),
                          showCheckmark: false,
                          onSelected: (on) => setState(() {
                            on
                                ? _selectedTags.add(tag)
                                : _selectedTags.remove(tag);
                          }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OrbSpacing.xl),
          Text('Mood colours', style: text.titleSmall),
          const SizedBox(height: OrbSpacing.sm),
          Wrap(
            spacing: OrbSpacing.sm,
            runSpacing: OrbSpacing.sm,
            children: [
              for (final mood in Mood.values)
                Tooltip(
                  message: mood.name,
                  child: CircleAvatar(radius: 16, backgroundColor: mood.color),
                ),
            ],
          ),
          const SizedBox(height: OrbSpacing.xl),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Your first name or nickname',
              helperText:
                  "I'll use it when I talk to you. Only you will see it.",
            ),
          ),
          const SizedBox(height: OrbSpacing.xl),
          FilledButton(onPressed: () {}, child: const Text("Let's begin")),
          const SizedBox(height: OrbSpacing.sm),
          OutlinedButton(onPressed: () {}, child: const Text('Edit today')),
          const SizedBox(height: OrbSpacing.sm),
          TextButton(
            onPressed: () {},
            child: const Text('Suggest another name'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.public), label: 'Space'),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            label: 'Quest',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
