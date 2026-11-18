import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/shared/copy.dart';

void main() {
  group('HomeCopy.greetingFor', () {
    String greet(Trait trait, int? level) => HomeCopy.greetingFor(
      trait: trait,
      level: level,
      userName: 'Dara',
      pigName: 'Mochi',
    );

    test('before check-in it is the before-check-in greeting', () {
      for (final trait in Trait.values) {
        expect(
          greet(trait, null),
          HomeCopy.greetingBefore(
            trait: trait,
            userName: 'Dara',
            pigName: 'Mochi',
          ),
        );
      }
    });

    for (final trait in Trait.values) {
      for (final level in [1, 2, 3, 4, 5]) {
        test('${trait.name} at level $level has its own line', () {
          final line = greet(trait, level);
          expect(line, isNotEmpty);
          expect(line, contains('Dara'));
          expect(line, isNot(contains(r'$')));
        });
      }
    }

    test('all 15 lines are different', () {
      final lines = {
        for (final trait in Trait.values)
          for (final level in [1, 2, 3, 4, 5]) greet(trait, level),
      };
      expect(lines, hasLength(15));
    });

    test('Rough and Low never judge or sound disappointed', () {
      const banned = [
        'disappoint',
        'should',
        'again?',
        'why',
        'cheer up',
        'come on',
        'at least',
        '!',
      ];
      for (final trait in Trait.values) {
        for (final level in [1, 2]) {
          final line = greet(trait, level).toLowerCase();
          for (final word in banned) {
            expect(line, isNot(contains(word)), reason: '$trait $level');
          }
        }
      }
    });
  });
}
