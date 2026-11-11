import 'package:intl/intl.dart';

import '../data/repositories/sadar_repository.dart';
import '../models/habit_entry.dart';
import 'focus_session_contract.dart';

class FocusClockCallbackHandler {
  static Future<bool> apply(Uri uri, SadarRepository repository) async {
    final result = FocusSessionContract.parseSadarCompletedUri(uri);
    if (result == null || !result.isCompleted) return false;
    final habit = await repository.getHabitById(result.habitId);
    if (habit == null) return false;

    final date = DateFormat('yyyy-MM-dd').format(result.startedAt);
    await repository.recordEntryStatus(
      habitId: habit.id,
      dateString: date,
      status: HabitStatus.yes,
      valueCompleted: result.actualDurationMinutes,
      targetSnapshot: habit.target,
      actualDurationMinutes: result.actualDurationMinutes,
      source: 'focus_clock',
      completedAt: result.endedAt,
    );
    return true;
  }
}
