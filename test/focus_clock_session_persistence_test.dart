import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:sadar/data/isar_service.dart';
import 'package:sadar/data/repositories/sadar_repository.dart';
import 'package:sadar/models/habit.dart';

void main() {
  late Directory directory;
  late Isar isar;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('sadar-focus-session-');
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      IsarService.schemas,
      directory: directory.path,
      name: 'sadar-focus-session-test',
      inspector: false,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test(
    'persists unique session IDs and aggregates each session once',
    () async {
      final repository = SadarRepository(isar);
      final habit = Habit()
        ..name = 'Study LKS'
        ..colorValue = 0xFF607D8B
        ..createdAt = DateTime(2026, 11, 11);
      final habitId = await repository.upsertHabit(habit);
      final startedAt = DateTime(2026, 11, 11, 16, 0);
      final completedAt = DateTime(2026, 11, 11, 16, 25);

      final recorded = await repository.recordFocusClockSession(
        sessionId: 'session-persisted',
        habitId: habitId,
        dateString: '2026-11-11',
        startedAt: startedAt,
        durationMinutes: 25,
        targetSnapshot: habit.target,
        completedAt: completedAt,
      );
      final duplicate = await repository.recordFocusClockSession(
        sessionId: 'session-persisted',
        habitId: habitId,
        dateString: '2026-11-11',
        startedAt: startedAt,
        durationMinutes: 25,
        targetSnapshot: habit.target,
        completedAt: completedAt,
      );

      expect(recorded, isTrue);
      expect(duplicate, isFalse);
      await isar.close();
      isar = await Isar.open(
        IsarService.schemas,
        directory: directory.path,
        name: 'sadar-focus-session-test',
        inspector: false,
      );
      final reopenedRepository = SadarRepository(isar);
      expect(
        await reopenedRepository.recordFocusClockSession(
          sessionId: 'session-persisted',
          habitId: habitId,
          dateString: '2026-11-11',
          startedAt: startedAt,
          durationMinutes: 25,
          targetSnapshot: habit.target,
          completedAt: completedAt,
        ),
        isFalse,
      );
      final snapshots = StreamIterator(
        reopenedRepository.watchFutureSelfSnapshot('2026-11-11'),
      );
      expect(await snapshots.moveNext(), isTrue);
      final nextSnapshotFuture = snapshots.moveNext();
      expect(
        await reopenedRepository.recordFocusClockSession(
          sessionId: 'session-second',
          habitId: habitId,
          dateString: '2026-11-11',
          startedAt: completedAt,
          durationMinutes: 10,
          targetSnapshot: habit.target,
          completedAt: completedAt.add(const Duration(minutes: 10)),
        ),
        isTrue,
      );
      expect(
        await nextSnapshotFuture.timeout(const Duration(seconds: 2)),
        isTrue,
      );
      expect(snapshots.current.activities.single.actualDurationMinutes, 35);
      await snapshots.cancel();
      expect(
        await reopenedRepository.getFocusClockSessionsForDateRange(
          '2026-11-11',
          '2026-11-11',
        ),
        hasLength(2),
      );
      final entries = await reopenedRepository.getEntriesForDateRange(
        '2026-11-11',
        '2026-11-11',
      );
      expect(entries.single.actualDurationMinutes, 35);
    },
  );
}
