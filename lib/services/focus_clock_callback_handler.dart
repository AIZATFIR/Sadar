import 'package:intl/intl.dart';

import '../data/repositories/sadar_repository.dart';
import 'focus_session_contract.dart';

class FocusClockCallbackHandler {
  static Future<bool> apply(Uri uri, SadarRepository repository) async {
    final result =
        FocusSessionContract.parseSadarCompletedUri(uri) ??
        FocusSessionContract.parseSadarWebCompletedUri(uri);
    if (result == null || !result.isCompleted) return false;
    final habit = await repository.getHabitById(result.habitId);
    if (habit == null) return false;

    final date = DateFormat('yyyy-MM-dd').format(result.startedAt);
    return repository.recordFocusClockSession(
      sessionId: result.sessionId,
      habitId: habit.id,
      dateString: date,
      startedAt: result.startedAt,
      targetSnapshot: habit.target,
      durationMinutes: result.actualDurationMinutes,
      completedAt: result.endedAt,
    );
  }
}
