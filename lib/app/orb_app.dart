import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'theme/theme_preview_screen.dart';

/// The root widget of the app.
///
/// It shows the theme preview until the go_router tab shell (PMG6-47)
/// replaces it.
class OrbApp extends StatelessWidget {
  const OrbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const ThemePreviewScreen(),
    );
  }
}
