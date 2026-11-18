import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/shared/pig_pose.dart';

void main() {
  test('each level has its own pose, and no check-in is curious', () {
    expect(PigPose.forLevel(null), PigPose.curious);
    expect(PigPose.forLevel(1), PigPose.comforting);
    expect(PigPose.forLevel(2), PigPose.listening);
    expect(PigPose.forLevel(3), PigPose.calm);
    expect(PigPose.forLevel(4), PigPose.joyful);
    expect(PigPose.forLevel(5), PigPose.cheering);
    expect({for (var l = 1; l <= 5; l++) PigPose.forLevel(l)}, hasLength(5));
  });

  testWidgets('every pose SVG is bundled and uses no masks or filters', (
    tester,
  ) async {
    for (final pose in PigPose.values) {
      final svg = await tester.runAsync(
        () => rootBundle.loadString(pose.asset, cache: false),
      );
      expect(svg, startsWith('<svg'), reason: pose.name);
      expect(svg, isNot(contains('<mask')), reason: pose.name);
      expect(svg, isNot(contains('<filter')), reason: pose.name);
    }
  });
}
