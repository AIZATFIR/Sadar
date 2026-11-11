import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sadar/data/repositories/sadar_repository.dart';
import 'package:sadar/models/habit_entry.dart';
import 'package:sadar/services/focus_clock_callback_handler.dart';
import 'package:sadar/services/focus_session_contract.dart';

void main() {
  test(
    'records a completed Focus Clock session against its Sadar habit',
    () async {
      final repository = SadarRepository(null);
      final habit = (await repository.getHabits()).first;
      final endedAt = DateTime(2026, 11, 11, 16, 30);
      final uri = FocusSessionContract.buildSadarCompletedUri(
        FocusSessionResult(
          sessionId: 'session-1',
          habitId: habit.id,
          startedAt: endedAt.subtract(const Duration(minutes: 25)),
          endedAt: endedAt,
          actualDurationMinutes: 25,
          status: 'completed',
        ),
      );

      final applied = await FocusClockCallbackHandler.apply(uri, repository);
      final date = DateFormat('yyyy-MM-dd').format(endedAt);
      final entry = (await repository.getEntriesForDateRange(
        date,
        date,
      )).single;

      expect(applied, isTrue);
      expect(entry.habitId, habit.id);
      expect(entry.status, HabitStatus.yes);
      expect(entry.actualDurationMinutes, 25);
      expect(entry.source, 'focus_clock');
    },
  );

  test('does not mark a cancelled external session complete', () async {
    final repository = SadarRepository(null);
    final habit = (await repository.getHabits()).first;
    final now = DateTime(2026, 11, 11, 16, 30);
    final uri = FocusSessionContract.buildSadarCompletedUri(
      FocusSessionResult(
        sessionId: 'session-2',
        habitId: habit.id,
        startedAt: now.subtract(const Duration(minutes: 5)),
        endedAt: now,
        actualDurationMinutes: 5,
        status: 'cancelled',
      ),
    );

    final applied = await FocusClockCallbackHandler.apply(uri, repository);
    final date = DateFormat('yyyy-MM-dd').format(now);

    expect(applied, isFalse);
    expect(await repository.getEntriesForDateRange(date, date), isEmpty);
  });
}
