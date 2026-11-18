import 'package:flutter/foundation.dart';

/// One day's check-in, as the app sees it.
///
/// [level] alone is a complete check-in. [emotion], [note] and [tagIds]
/// are optional extras.
@immutable
class CheckIn {
  const CheckIn({
    required this.id,
    required this.day,
    required this.level,
    this.emotion,
    this.note,
    this.tagIds = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;

  /// The local date as yyyy-MM-dd. See [dayKey].
  final String day;

  /// 1 (Rough) to 5 (Great).
  final int level;

  /// A `Mood` name such as "happy", or null.
  final String? emotion;
  final String? note;

  /// Apple State of Mind association ids, e.g. "work" or "selfCare".
  final Set<String> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      other is CheckIn &&
      other.id == id &&
      other.day == day &&
      other.level == level &&
      other.emotion == emotion &&
      other.note == note &&
      setEquals(other.tagIds, tagIds) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    day,
    level,
    emotion,
    note,
    Object.hashAllUnordered(tagIds),
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'CheckIn(day: $day, level: $level, emotion: $emotion, '
      'note: $note, tagIds: $tagIds)';
}

/// The day a moment belongs to: its local date as yyyy-MM-dd.
///
/// The day rolls over at local midnight, so 23:59 and 00:01 are different
/// days.
String dayKey(DateTime moment) {
  final local = moment.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-'
      '${two(local.month)}-${two(local.day)}';
}
