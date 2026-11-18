import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [UncontrolledProviderScope] that disposes [container] together with the
/// widget tree.
///
/// Tests that read a [ProviderContainer] directly need this instead of
/// `addTearDown(container.dispose)`: flutter_test checks for pending timers
/// (such as `todayCheckInProvider`'s midnight refresh) when the tree is
/// disposed, before tear-downs run.
class ContainerScope extends StatefulWidget {
  const ContainerScope({
    super.key,
    required this.container,
    required this.child,
  });

  final ProviderContainer container;
  final Widget child;

  @override
  State<ContainerScope> createState() => _ContainerScopeState();
}

class _ContainerScopeState extends State<ContainerScope> {
  @override
  void dispose() {
    widget.container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UncontrolledProviderScope(
    container: widget.container,
    child: widget.child,
  );
}
