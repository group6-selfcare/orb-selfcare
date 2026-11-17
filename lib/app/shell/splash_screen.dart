import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A blank screen in the app's background colour, shown on cold start
/// while the profile loads. It is usually up for only a frame or two.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: OrbColors.background, child: SizedBox.expand());
}
