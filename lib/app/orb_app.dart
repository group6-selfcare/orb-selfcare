import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/orb_scroll_behavior.dart';

/// The root widget of the app.
class OrbApp extends ConsumerWidget {
  const OrbApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Orb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      scrollBehavior: const OrbScrollBehavior(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
