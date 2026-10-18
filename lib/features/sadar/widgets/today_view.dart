import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../models/daily_reflection.dart';
import '../../../models/habit.dart';
import '../../../models/habit_entry.dart';
import '../../../providers/sadar_providers.dart';
import 'habit_editor_sheet.dart';
import 'reflection_sheet.dart';
import 'sadar_ypt_focus_view.dart';

class TodayView extends ConsumerStatefulWidget {
  const TodayView({super.key});

  @override
  ConsumerState<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends ConsumerState<TodayView> {
  late Timer _clockTimer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _greeting() {
    final hour = _currentTime.hour;
    if (hour < 12) return 'Selamat pagi, Zafir.';
    if (hour < 17) return 'Selamat siang, Zafir.';
    return 'Selamat malam, Zafir.';
  }

  String get _todayStr {
    final y = _currentTime.year.toString().padLeft(4, '0');
    final m = _currentTime.month.toString().padLeft(2, '0');
    final d = _currentTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _openHabitEditor([Habit? habit]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitEditorSheet(
        habit: habit,
        onSaved: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _openReflection(DailyReflection? existingReflection) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReflectionSheet(
        dateString: _todayStr,
        existingReflection: existingReflection,
        onSaved: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _startYptFocus(Habit habit) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => SadarYptFocusView(
          habit: habit,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  Future<void> _incrementCount(Habit habit, int delta) async {
    HapticFeedback.selectionClick();
    await ref.read(sadarRepoProvider).incrementHabitCount(
      habitId: habit.id,
      dateString: _todayStr,
      delta: delta,
    );
  }

  Future<void> _toggleComplete(Habit habit, HabitStatus currentStatus) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(sadarRepoProvider);

    if (habit.effectiveHabitType == 'progression') {
      if (currentStatus != HabitStatus.yes) {
        final step = habit.currentStep;
        final target = step.target;
        await repo.recordEntryStatus(
          habitId: habit.id,
          dateString: _todayStr,
          status: HabitStatus.yes,
          valueCompleted: target,
        );
        await repo.advanceProgression(habit.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                step.isRest
                    ? '💤 Rest Day tercatat! Lanjut ke jadwal berikutnya.'
                    : '🔥 ${step.title} selesai! Lanjut ke jadwal berikutnya.',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await repo.recordEntryStatus(
          habitId: habit.id,
          dateString: _todayStr,
          status: HabitStatus.unmarked,
          valueCompleted: 0,
        );
      }
      return;
    }

    final newStatus = currentStatus == HabitStatus.yes ? HabitStatus.unmarked : HabitStatus.yes;
    await repo.recordEntryStatus(
      habitId: habit.id,
      dateString: _todayStr,
      status: newStatus,
      valueCompleted: newStatus == HabitStatus.yes ? habit.target : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final rangeQuery = DateRangeQuery(start: _todayStr, end: _todayStr);
    final entriesAsync = ref.watch(habitEntriesStreamProvider(rangeQuery));
    final reflectionAsync = ref.watch(dailyReflectionProvider(_todayStr));

    final entriesMap = <int, HabitEntry>{};
    entriesAsync.whenData((entries) {
      for (final e in entries) {
        entriesMap[e.habitId] = e;
      }
    });

    final timeFormatted = DateFormat('h:mm a').format(_currentTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Salutation & Core Philosophy Prompt
            Text(
              _greeting(),
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: AppPalette.text,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'How do you want to live today?',
              style: TextStyle(
                fontSize: 15,
                color: AppPalette.textDim,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 28),

            // 2. TODAY Header Line
            Row(
              children: [
                const Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                    color: AppPalette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: AppPalette.appleGlassBorder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. List of Things
            habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'No things chosen for today yet.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppPalette.textDim,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ApplePressable(
                          onTap: () => _openHabitEditor(),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppPalette.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppPalette.accent.withValues(alpha: 0.35),
                                width: 0.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 18, color: AppPalette.accent),
                                SizedBox(width: 6),
                                Text(
                                  'Pilih yang Bermakna Hari Ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.accent,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                int completedCount = 0;
                for (final h in habits) {
                  final entry = entriesMap[h.id];
                  if (entry?.status == HabitStatus.yes) {
                    completedCount++;
                  }
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        final entry = entriesMap[habit.id];
                        final isDone = entry?.status == HabitStatus.yes;
                        final habitColor = Color(habit.colorValue);
                        final habitType = habit.effectiveHabitType;

                        return _buildHabitCard(
                          habit: habit,
                          entry: entry,
                          isDone: isDone,
                          habitColor: habitColor,
                          habitType: habitType,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // + Add & Progress Line
                    Row(
                      children: [
                        ApplePressable(
                          onTap: () => _openHabitEditor(),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppPalette.appleGlassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: AppPalette.accent),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    color: AppPalette.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$completedCount / ${habits.length} done',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: AppPalette.textDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFEF4444))),
            ),

            const SizedBox(height: 24),
            Container(height: 0.5, color: AppPalette.appleGlassBorder),
            const SizedBox(height: 24),

            // 4. Today's Reflection Card
            reflectionAsync.when(
              data: (reflection) {
                final hasReflected = reflection != null &&
                    (reflection.proudOfToday.isNotEmpty || reflection.note.isNotEmpty);

                return ApplePressable(
                  onTap: () => _openReflection(reflection),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppPalette.appleGlassBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasReflected
                            ? AppPalette.accent.withValues(alpha: 0.45)
                            : AppPalette.appleGlassBorder,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppPalette.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppPalette.accent.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.favorite_border_rounded, size: 16, color: AppPalette.accent),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Today's reflection",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: AppPalette.text,
                              ),
                            ),
                            const Spacer(),
                            if (hasReflected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppPalette.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppPalette.accent.withValues(alpha: 0.35),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  _feelingLabel(reflection.feeling),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppPalette.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              )
                            else
                              const Text(
                                '[ How did today feel? ]',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: -0.1,
                                  color: AppPalette.textDim,
                                ),
                              ),
                          ],
                        ),
                        if (hasReflected && reflection.proudOfToday.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            '“${reflection.proudOfToday}”',
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppPalette.text,
                              height: 1.45,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 48),

            // 5. Calm Clock Display at bottom
            Center(
              child: Text(
                timeFormatted,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: AppPalette.textDim,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    ),
  );
}

  String _feelingLabel(ReflectionFeeling feeling) {
    switch (feeling) {
      case ReflectionFeeling.proud:
        return 'Proud 🌟';
      case ReflectionFeeling.good:
        return 'Good 🌿';
      case ReflectionFeeling.okay:
        return 'Okay ☁️';
      case ReflectionFeeling.notSatisfied:
        return 'Reflecting 🌧️';
    }
  }

  Widget _buildHabitCard({
    required Habit habit,
    required HabitEntry? entry,
    required bool isDone,
    required Color habitColor,
    required String habitType,
  }) {
    String title = habit.name;
    String subtitle = '';
    Widget? trailingAction;

    if (habitType == 'timed') {
      final whitelistStr = habit.allowedPackages.isNotEmpty
          ? ' • ${habit.allowedPackages.length} apps'
          : '';
      subtitle = '${habit.target} min$whitelistStr';
      if (!isDone) {
        trailingAction = ApplePressable(
          onTap: () => _startYptFocus(habit),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppPalette.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.accent.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 15, color: AppPalette.accent),
                SizedBox(width: 4),
                Text(
                  'Fokus YPT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.accent,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (habitType == 'progression') {
      final step = habit.currentStep;
      if (step.isRest) {
        title = '${habit.name}: 💤 ${step.dayName} (Rest Day)';
        subtitle = 'Hari pemulihan & istirahat otot';
        if (!isDone) {
          trailingAction = ApplePressable(
            onTap: () => _toggleComplete(habit, entry?.status ?? HabitStatus.unmarked),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bedtime_rounded, size: 14, color: Color(0xFF818CF8)),
                  SizedBox(width: 4),
                  Text(
                    'Ambil Rest',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF818CF8),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        title = '${habit.name}: ${step.dayName} — ${step.title}';
        subtitle = '${step.target}x repetisi (Terkunci)';
        if (!isDone) {
          trailingAction = ApplePressable(
            onTap: () => _toggleComplete(habit, entry?.status ?? HabitStatus.unmarked),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFDE047).withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded, size: 14, color: Color(0xFFFDE047)),
                  const SizedBox(width: 4),
                  Text(
                    '${step.target}x Selesai',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFDE047),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } else if (habitType == 'hybrid') {
      subtitle = '${habit.hybridSets} Set @ ${habit.hybridDurationSeconds}s';
      if (!isDone) {
        trailingAction = ApplePressable(
          onTap: () => _startYptFocus(habit),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF472B6).withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: Color(0xFFF472B6)),
                SizedBox(width: 4),
                Text(
                  'Mulai',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF472B6),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // count mode
      if (habit.target > 1) {
        final currentVal = entry?.valueCompleted ?? 0;
        subtitle = '$currentVal / ${habit.target} kali';
        trailingAction = Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.appleGlassBorder, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ApplePressable(
                onTap: currentVal > 0 ? () => _incrementCount(habit, -1) : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.remove_rounded,
                    size: 16,
                    color: currentVal > 0 ? AppPalette.text : Colors.white24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '$currentVal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDone ? AppPalette.appleSuccess : AppPalette.text,
                  ),
                ),
              ),
              ApplePressable(
                onTap: () => _incrementCount(habit, 1),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.add_rounded, size: 16, color: AppPalette.accent),
                ),
              ),
            ],
          ),
        );
      } else {
        subtitle = 'Target harian';
      }
    }

    String badgeLabel = '🔢 Count';
    Color badgeColor = const Color(0xFF3B82F6);
    if (habitType == 'timed') {
      badgeLabel = '⏱️ YPT';
      badgeColor = AppPalette.accent;
    } else if (habitType == 'progression') {
      badgeLabel = '🏋️ Bodybuilding';
      badgeColor = const Color(0xFFEAB308);
    } else if (habitType == 'hybrid') {
      badgeLabel = '⚡ Hybrid';
      badgeColor = const Color(0xFFEC4899);
    }

    return ApplePressable(
      onTap: () => _openHabitEditor(habit),
      onLongPress: () => _openHabitEditor(habit),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isDone
              ? AppPalette.appleSuccessGlass
              : AppPalette.appleGlassBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone
                ? AppPalette.appleSuccessBorder
                : AppPalette.appleGlassBorder,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Apple Completion Checkbox / Ring
            ApplePressable(
              onTap: () => _toggleComplete(habit, entry?.status ?? HabitStatus.unmarked),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone ? AppPalette.appleSuccess : Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? AppPalette.appleSuccess
                        : Colors.white.withValues(alpha: 0.22),
                    width: isDone ? 0 : 1.5,
                  ),
                  boxShadow: isDone
                      ? [
                          BoxShadow(
                            color: AppPalette.appleSuccess.withValues(alpha: 0.45),
                            blurRadius: 8,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 13),

            // Emoji Icon
            Text(habit.iconKey, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 11),

            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isDone ? FontWeight.w500 : FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDone ? AppPalette.textDim : AppPalette.text,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            decorationColor: AppPalette.textDim,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.28),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: -0.1,
                        color: AppPalette.textDim,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (trailingAction != null) ...[
              const SizedBox(width: 8),
              trailingAction,
            ],

            // Edit button with subtle press feedback
            ApplePressable(
              onTap: () => _openHabitEditor(habit),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.more_vert_rounded, size: 18, color: Colors.white30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
