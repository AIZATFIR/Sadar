import 'dart:async';
import 'package:isar/isar.dart';

import '../../models/habit.dart';
import '../../models/habit_entry.dart';
import '../../models/daily_reflection.dart';
import '../../models/timer_session.dart';
import '../../models/future_self.dart';

class RepetitionStat {
  final Habit habit;
  final int totalDays;
  final int totalMinutes;

  const RepetitionStat({
    required this.habit,
    required this.totalDays,
    required this.totalMinutes,
  });
}

class DailyFulfillmentSummary {
  final String dateString;
  final int completedCount;
  final int totalCount;

  const DailyFulfillmentSummary({
    required this.dateString,
    required this.completedCount,
    required this.totalCount,
  });

  double get ratio => totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
  bool get isFulfilled => completedCount > 0 && completedCount >= totalCount;
}

class AwarenessStats {
  final Map<int, int> habitCompletedCounts;
  final Map<int, int> habitMissedCounts;
  final List<Habit> neglectedHabits;
  final List<Habit> consistentHabits;

  const AwarenessStats({
    required this.habitCompletedCounts,
    required this.habitMissedCounts,
    required this.neglectedHabits,
    required this.consistentHabits,
  });
}

class SadarRepository {
  SadarRepository(this._isar, {bool seedSampleEntries = false}) {
    if (_isar == null) {
      for (final h in _defaultHabits()) {
        _memHabits[h.id] = h;
      }
      if (seedSampleEntries) {
        _seedSampleEntries();
      }
    }
  }

  final Isar? _isar;

  // In-Memory storage for tests / fallback
  final Map<int, Habit> _memHabits = {};
  final Map<String, HabitEntry> _memEntries = {}; // Key: "$habitId-$dateString"
  final Map<String, DailyReflection> _memReflections = {}; // Key: "$dateString"
  int _memHabitIdCounter = 100;
  int _memEntryIdCounter = 1000;

  final StreamController<void> _habitsStreamCtrl = StreamController<void>.broadcast();
  final StreamController<void> _entriesStreamCtrl = StreamController<void>.broadcast();
  final StreamController<void> _futureSelfStreamCtrl = StreamController<void>.broadcast();
  String _futureSelfGoal = 'Membangun kehidupan bermakna dengan disiplin & kesadaran.';

  // ──────────────────────────────────────────────────────────────────────────
  // Habits
  // ──────────────────────────────────────────────────────────────────────────

  Stream<List<Habit>> watchHabits() {
    if (_isar == null) {
      return _watchMemHabits();
    }
    return _isar.habits
        .filter()
        .isArchivedEqualTo(false)
        .sortByOrderIndex()
        .thenByCreatedAt()
        .watch(fireImmediately: true);
  }

  Stream<List<Habit>> _watchMemHabits() async* {
    yield _getMemHabitsList();
    await for (final _ in _habitsStreamCtrl.stream) {
      yield _getMemHabitsList();
    }
  }

  List<Habit> _getMemHabitsList() {
    final list = _memHabits.values.where((h) => !h.isArchived).toList();
    list.sort((a, b) {
      final ord = a.orderIndex.compareTo(b.orderIndex);
      if (ord != 0) return ord;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  Future<List<Habit>> getHabits() async {
    if (_isar == null) {
      return _getMemHabitsList();
    }
    return _isar.habits
        .filter()
        .isArchivedEqualTo(false)
        .sortByOrderIndex()
        .thenByCreatedAt()
        .findAll();
  }

  Future<int> upsertHabit(Habit habit) async {
    habit.updatedAt = DateTime.now();
    if (_isar == null) {
      if (habit.id == Isar.autoIncrement || habit.id <= 0) {
        habit.id = _memHabitIdCounter++;
      }
      _memHabits[habit.id] = habit;
      _habitsStreamCtrl.add(null);
      _futureSelfStreamCtrl.add(null);
      return habit.id;
    }
    final id = await _isar.writeTxn(() => _isar.habits.put(habit));
    _futureSelfStreamCtrl.add(null);
    return id;
  }

  Future<bool> deleteHabit(int id, {bool hardDelete = false}) async {
    if (_isar == null) {
      if (hardDelete) {
        _memHabits.remove(id);
      } else {
        final h = _memHabits[id];
        if (h != null) h.isArchived = true;
      }
      _habitsStreamCtrl.add(null);
      _futureSelfStreamCtrl.add(null);
      return true;
    }

    if (hardDelete) {
      final res = await _isar.writeTxn(() => _isar.habits.delete(id));
      _futureSelfStreamCtrl.add(null);
      return res;
    } else {
      final h = await _isar.habits.get(id);
      if (h != null) {
        h.isArchived = true;
        h.updatedAt = DateTime.now();
        await _isar.writeTxn(() => _isar.habits.put(h));
        _futureSelfStreamCtrl.add(null);
        return true;
      }
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Habit Entries
  // ──────────────────────────────────────────────────────────────────────────

  Stream<List<HabitEntry>> watchEntriesForDateRange(String startDate, String endDate) {
    if (_isar == null) {
      return _watchMemEntries(startDate, endDate);
    }
    return _isar.habitEntrys
        .filter()
        .dateStringBetween(startDate, endDate)
        .watch(fireImmediately: true);
  }

  Stream<List<HabitEntry>> _watchMemEntries(String startDate, String endDate) async* {
    yield _getMemEntriesList(startDate, endDate);
    await for (final _ in _entriesStreamCtrl.stream) {
      yield _getMemEntriesList(startDate, endDate);
    }
  }

  List<HabitEntry> _getMemEntriesList(String startDate, String endDate) {
    return _memEntries.values
        .where((e) => e.dateString.compareTo(startDate) >= 0 && e.dateString.compareTo(endDate) <= 0)
        .toList();
  }

  Future<List<HabitEntry>> getEntriesForDateRange(String startDate, String endDate) async {
    if (_isar == null) {
      return _getMemEntriesList(startDate, endDate);
    }
    return _isar.habitEntrys
        .filter()
        .dateStringBetween(startDate, endDate)
        .findAll();
  }

  Future<Habit?> getHabitById(int id) async {
    if (_isar == null) return _memHabits[id];
    return _isar.habits.get(id);
  }

  Future<HabitEntry> recordEntryStatus({
    required int habitId,
    required String dateString,
    required HabitStatus status,
    int? valueCompleted,
    int? targetSnapshot,
    int? actualDurationMinutes,
    String? source,
    DateTime? completedAt,
    String? note,
  }) async {
    final now = DateTime.now();
    final habit = await getHabitById(habitId);
    final resolvedTargetSnapshot = targetSnapshot ?? habit?.target ?? 0;
    final resolvedActualDuration = actualDurationMinutes ?? valueCompleted ?? (status == HabitStatus.yes ? resolvedTargetSnapshot : 0);
    final resolvedSource = source ?? 'manual';
    final resolvedCompletedAt = completedAt ?? (status == HabitStatus.yes ? now : null);

    if (_isar == null) {
      final key = '$habitId-$dateString';
      final existing = _memEntries[key];
      final entry = existing ?? (HabitEntry()
        ..id = _memEntryIdCounter++
        ..habitId = habitId
        ..dateString = dateString
        ..createdAt = now);

      entry.status = status;
      if (valueCompleted != null) entry.valueCompleted = valueCompleted;
      entry.targetSnapshot = entry.targetSnapshot > 0 ? entry.targetSnapshot : resolvedTargetSnapshot;
      entry.actualDurationMinutes = resolvedActualDuration;
      entry.completedAt = resolvedCompletedAt;
      entry.source = resolvedSource;
      if (note != null) entry.note = note;
      entry.updatedAt = now;

      _memEntries[key] = entry;
      _entriesStreamCtrl.add(null);
      _futureSelfStreamCtrl.add(null);
      return entry;
    }

    final res = await _isar.writeTxn(() async {
      final existing = await _isar.habitEntrys
          .filter()
          .habitIdEqualTo(habitId)
          .dateStringEqualTo(dateString)
          .findFirst();

      final entry = existing ?? (HabitEntry()
        ..habitId = habitId
        ..dateString = dateString
        ..createdAt = now);

      entry.status = status;
      if (valueCompleted != null) entry.valueCompleted = valueCompleted;
      entry.targetSnapshot = entry.targetSnapshot > 0 ? entry.targetSnapshot : resolvedTargetSnapshot;
      entry.actualDurationMinutes = resolvedActualDuration;
      entry.completedAt = resolvedCompletedAt;
      entry.source = resolvedSource;
      if (note != null) entry.note = note;
      entry.updatedAt = now;

      await _isar.habitEntrys.put(entry);
      return entry;
    });
    _futureSelfStreamCtrl.add(null);
    return res;
  }

  Future<void> advanceProgression(int habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return;
    final totalSteps = habit.progressionSteps.length;
    if (totalSteps <= 0) return;
    habit.currentProgressionIndex = (habit.currentProgressionIndex + 1) % totalSteps;
    await upsertHabit(habit);
  }

  Future<HabitEntry> incrementHabitCount({
    required int habitId,
    required String dateString,
    required int delta,
  }) async {
    final habit = await getHabitById(habitId);
    final target = habit?.target ?? 1;
    final currentEntries = await getEntriesForDateRange(dateString, dateString);
    final existing = currentEntries.where((e) => e.habitId == habitId).firstOrNull;
    final currentVal = existing?.valueCompleted ?? 0;
    final newVal = (currentVal + delta).clamp(0, 9999);
    final newStatus = newVal >= target ? HabitStatus.yes : (newVal > 0 ? HabitStatus.unmarked : HabitStatus.unmarked);

    return recordEntryStatus(
      habitId: habitId,
      dateString: dateString,
      status: newStatus,
      valueCompleted: newVal,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Daily Fulfillment & Awareness Stats
  // ──────────────────────────────────────────────────────────────────────────

  Future<DailyFulfillmentSummary> getDailyFulfillment(String dateString) async {
    final habits = await getHabits();
    final totalCount = habits.length;

    int completed = 0;
    if (_isar == null) {
      for (final h in habits) {
        final entry = _memEntries['${h.id}-$dateString'];
        if (entry != null && entry.status == HabitStatus.yes) {
          completed++;
        }
      }
    } else {
      final entries = await _isar.habitEntrys
          .filter()
          .dateStringEqualTo(dateString)
          .statusEqualTo(HabitStatus.yes)
          .findAll();
      completed = entries.length;
    }

    return DailyFulfillmentSummary(
      dateString: dateString,
      completedCount: completed,
      totalCount: totalCount,
    );
  }

  Future<DailyReflection?> getDailyReflection(String dateString) async {
    if (_isar == null) {
      return _memReflections[dateString];
    }
    return _isar.dailyReflections.filter().dateStringEqualTo(dateString).findFirst();
  }

  Future<void> saveDailyReflection(DailyReflection reflection) async {
    reflection.updatedAt = DateTime.now();
    if (_isar == null) {
      _memReflections[reflection.dateString] = reflection;
      _futureSelfStreamCtrl.add(null);
      return;
    }
    await _isar.writeTxn(() => _isar.dailyReflections.put(reflection));
    _futureSelfStreamCtrl.add(null);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Future Self Widget & Gratitude Operations
  // ──────────────────────────────────────────────────────────────────────────

  Future<String> getFutureSelfGoal() async => _futureSelfGoal;

  Future<void> setFutureSelfGoal(String goal) async {
    _futureSelfGoal = goal.trim();
    _futureSelfStreamCtrl.add(null);
  }

  Future<void> addGratitudeEntry(String gratitude, [String? dateString]) async {
    final ds = dateString ?? _formatDate(DateTime.now());
    final trimmed = gratitude.trim();
    if (trimmed.isEmpty) return;

    final existing = await getDailyReflection(ds);
    final reflection = existing ?? (DailyReflection()
      ..dateString = ds
      ..feeling = ReflectionFeeling.good
      ..updatedAt = DateTime.now());

    if (reflection.proudOfToday.isEmpty) {
      reflection.proudOfToday = trimmed;
    } else {
      reflection.note = reflection.note.isEmpty
          ? '• $trimmed'
          : '${reflection.note}\n• $trimmed';
    }

    await saveDailyReflection(reflection);
  }

  Future<FutureSelfSnapshot> getFutureSelfSnapshot([String? dateString]) async {
    final ds = dateString ?? _formatDate(DateTime.now());
    final habits = await getHabits();
    final entries = await getEntriesForDateRange(ds, ds);
    final entriesMap = {for (final e in entries) e.habitId: e};
    final reflection = await getDailyReflection(ds);

    final activities = habits.map((h) {
      final entry = entriesMap[h.id];
      final isDone = entry?.status == HabitStatus.yes;
      return FutureSelfActivityItem(
        id: h.id,
        title: h.name,
        iconKey: h.iconKey,
        target: h.target,
        unit: h.unit,
        habitType: h.habitType,
        colorValue: h.colorValue,
        isCompleted: isDone,
        valueCompleted: entry?.valueCompleted ?? 0,
        actualDurationMinutes: entry?.actualDurationMinutes ?? 0,
        preferredTime: h.preferredTime,
      );
    }).toList();

    final gratitudeList = <String>[];
    if (reflection != null) {
      if (reflection.proudOfToday.trim().isNotEmpty) {
        gratitudeList.add(reflection.proudOfToday.trim());
      }
      if (reflection.note.trim().isNotEmpty) {
        final lines = reflection.note.split('\n');
        for (final l in lines) {
          final trimmed = l.trim();
          if (trimmed.startsWith('• ') || trimmed.startsWith('- ') || trimmed.startsWith('🙏 ')) {
            final cleaned = trimmed.replaceFirst(RegExp(r'^[•\-\s🙏]+'), '').trim();
            if (cleaned.isNotEmpty && !gratitudeList.contains(cleaned)) {
              gratitudeList.add(cleaned);
            }
          }
        }
      }
    }

    return FutureSelfSnapshot(
      dateString: ds,
      futureSelfGoal: _futureSelfGoal,
      activities: activities,
      gratitudeSnippet: gratitudeList.isNotEmpty ? gratitudeList.first : null,
      gratitudeEntries: gratitudeList,
      updatedAt: DateTime.now(),
    );
  }

  Stream<FutureSelfSnapshot> watchFutureSelfSnapshot([String? dateString]) async* {
    final ds = dateString ?? _formatDate(DateTime.now());
    yield await getFutureSelfSnapshot(ds);
    await for (final _ in _futureSelfStreamCtrl.stream) {
      yield await getFutureSelfSnapshot(ds);
    }
  }

  Future<List<RepetitionStat>> getWhatIRepeat() async {
    final habits = await getHabits();
    final stats = <RepetitionStat>[];

    for (final h in habits) {
      int days = 0;
      int minutes = 0;
      if (_isar == null) {
        for (final entry in _memEntries.values) {
          if (entry.habitId == h.id && entry.status == HabitStatus.yes) {
            days++;
            minutes += entry.valueCompleted > 0 ? entry.valueCompleted : h.target;
          }
        }
      } else {
        final entries = await _isar.habitEntrys
            .filter()
            .habitIdEqualTo(h.id)
            .statusEqualTo(HabitStatus.yes)
            .findAll();
        days = entries.length;
        for (final e in entries) {
          minutes += e.valueCompleted > 0 ? e.valueCompleted : h.target;
        }
      }
      stats.add(RepetitionStat(
        habit: h,
        totalDays: days,
        totalMinutes: minutes,
      ));
    }

    stats.sort((a, b) => b.totalDays.compareTo(a.totalDays));
    return stats;
  }

  Future<AwarenessStats> getAwarenessStats({int daysBack = 30}) async {
    final habits = await getHabits();
    final habitCompletedCounts = <int, int>{};
    final habitMissedCounts = <int, int>{};

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysBack));
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(now);

    final entries = await getEntriesForDateRange(startStr, endStr);

    for (final e in entries) {
      if (e.status == HabitStatus.yes) {
        habitCompletedCounts[e.habitId] = (habitCompletedCounts[e.habitId] ?? 0) + 1;
      } else if (e.status == HabitStatus.no) {
        habitMissedCounts[e.habitId] = (habitMissedCounts[e.habitId] ?? 0) + 1;
      }
    }

    final consistent = <Habit>[];
    final neglected = <Habit>[];

    for (final h in habits) {
      final done = habitCompletedCounts[h.id] ?? 0;
      final missed = habitMissedCounts[h.id] ?? 0;
      if (done >= (daysBack * 0.4).round()) {
        consistent.add(h);
      } else if (missed > done || done == 0) {
        neglected.add(h);
      }
    }

    return AwarenessStats(
      habitCompletedCounts: habitCompletedCounts,
      habitMissedCounts: habitMissedCounts,
      neglectedHabits: neglected,
      consistentHabits: consistent,
    );
  }

  TimerSession? _memTimerSession;

  Future<TimerSession?> getActiveTimerSession() async {
    if (_isar == null) {
      return _memTimerSession;
    }
    return _isar.timerSessions.get(1);
  }

  Future<void> saveTimerSession(TimerSession session) async {
    session.id = 1;
    session.updatedAt = DateTime.now();
    if (_isar == null) {
      _memTimerSession = session;
      return;
    }
    await _isar.writeTxn(() => _isar.timerSessions.put(session));
  }

  Future<void> clearTimerSession() async {
    if (_isar == null) {
      _memTimerSession = null;
      return;
    }
    await _isar.writeTxn(() => _isar.timerSessions.delete(1));
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<Habit> _defaultHabits() => [
    Habit()
      ..id = 1
      ..name = 'Fokus Coding (LKS)'
      ..iconKey = '💻'
      ..target = 45
      ..unit = HabitUnit.min
      ..habitType = 'timed'
      ..timerEnabled = true
      ..colorValue = 0xFF10B981 // Emerald
      ..orderIndex = 0
      ..createdAt = DateTime.now(),
    Habit()
      ..id = 2
      ..name = 'Kalaam 1 Course'
      ..iconKey = '📖'
      ..target = 1
      ..unit = HabitUnit.count
      ..habitType = 'count'
      ..timerEnabled = false
      ..colorValue = 0xFF8B5CF6 // Purple
      ..orderIndex = 1
      ..createdAt = DateTime.now(),
    Habit()
      ..id = 3
      ..name = 'Push Up & Workout'
      ..iconKey = '🏋️'
      ..target = 20
      ..unit = HabitUnit.count
      ..habitType = 'progression'
      ..timerEnabled = false
      ..colorValue = 0xFFEAB308 // Amber
      ..orderIndex = 2
      ..createdAt = DateTime.now(),
    Habit()
      ..id = 4
      ..name = 'Plank & Core'
      ..iconKey = '⚡'
      ..target = 3
      ..unit = HabitUnit.min
      ..habitType = 'hybrid'
      ..hybridSets = 3
      ..hybridDurationSeconds = 60
      ..hybridRestSeconds = 30
      ..timerEnabled = true
      ..colorValue = 0xFFEC4899 // Pink
      ..orderIndex = 3
      ..createdAt = DateTime.now(),
    Habit()
      ..id = 5
      ..name = 'Sapa Burung / Mindful'
      ..iconKey = '🕊️'
      ..target = 1
      ..unit = HabitUnit.count
      ..habitType = 'count'
      ..timerEnabled = false
      ..colorValue = 0xFF06B6D4 // Cyan
      ..orderIndex = 4
      ..createdAt = DateTime.now(),
  ];

  void _seedSampleEntries() {
    final now = DateTime.now();
    for (int dayOffset = -6; dayOffset <= 0; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final ds = _formatDate(date);
      for (final h in _memHabits.values) {
        final isCompleted = ((h.id + dayOffset).abs() % 2 == 0) || (dayOffset == 0 && h.id <= 2);
        final entry = HabitEntry()
          ..id = _memEntryIdCounter++
          ..habitId = h.id
          ..dateString = ds
          ..status = isCompleted ? HabitStatus.yes : (dayOffset == 0 ? HabitStatus.unmarked : HabitStatus.skip)
          ..valueCompleted = isCompleted ? h.target : 0
          ..targetSnapshot = h.target
          ..actualDurationMinutes = isCompleted ? h.target : 0
          ..completedAt = isCompleted ? date : null
          ..source = 'system_seed'
          ..updatedAt = date;
        _memEntries['${h.id}-$ds'] = entry;
      }
    }
  }
}
