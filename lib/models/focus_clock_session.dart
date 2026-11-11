import 'package:isar/isar.dart';

part 'focus_clock_session.g.dart';

@collection
class FocusClockSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sessionId;

  @Index()
  late int habitId;

  @Index()
  late String dateString;

  late DateTime startedAt;
  late DateTime completedAt;
  late int durationMinutes;
}
