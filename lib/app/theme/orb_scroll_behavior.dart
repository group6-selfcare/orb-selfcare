import 'package:flutter/material.dart';

/// Scrolling for the whole app: lists stop at their edges, without
/// Android's stretch (or the older glow) when you pull past the end.
class OrbScrollBehavior extends MaterialScrollBehavior {
  const OrbScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
