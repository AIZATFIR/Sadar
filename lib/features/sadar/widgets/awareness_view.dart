import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../models/habit.dart';
import '../../../providers/sadar_providers.dart';

class AwarenessView extends ConsumerWidget {
  const AwarenessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awarenessAsync = ref.watch(awarenessStatsProvider);
    final habitsAsync = ref.watch(habitsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Philosophical Quote Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppPalette.appleGlassBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppPalette.appleGlassBorder,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 20,
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
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppPalette.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppPalette.accent.withValues(alpha: 0.35),
                                  width: 0.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove_red_eye_outlined, color: AppPalette.accent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'PRINSIP KESADARAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: AppPalette.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '"Until you make the unconscious conscious, it will direct your life and you will call it fate."',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppPalette.text,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Aplikasi ini hadir bukan untuk menghakimimu, melainkan untuk menyadarkan pola nyata yang berulang dalam hidupmu.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPalette.textDim,
                            height: 1.45,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Section 1: "Apa yang berulang kali kulakukan?"
              const Text(
                'APA YANG BERULANG KALI KAU LAKUKAN?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppPalette.textDim,
                ),
              ),
              const SizedBox(height: 12),

              awarenessAsync.when(
                data: (stats) {
                  return habitsAsync.when(
                    data: (habits) {
                      if (habits.isEmpty) {
                        return const Text(
                          'Belum ada data kebiasaan.',
                          style: TextStyle(color: AppPalette.textDim, fontSize: 13),
                        );
                      }

                      // Sort habits by completed sessions descending
                      final sorted = List<Habit>.from(habits)
                        ..sort((a, b) {
                          final countA = stats.habitCompletedCounts[a.id] ?? 0;
                          final countB = stats.habitCompletedCounts[b.id] ?? 0;
                          return countB.compareTo(countA);
                        });

                      return Column(
                        children: sorted.map((h) {
                          final completedSessions = stats.habitCompletedCounts[h.id] ?? 0;
                          final habitColor = Color(h.colorValue);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppPalette.appleGlassBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppPalette.appleGlassBorder,
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
                                Text(h.iconKey, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: AppPalette.text,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$completedSessions sesi terpenuhi (30 hari terakhir)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppPalette.textDim,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: habitColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: habitColor.withValues(alpha: 0.35),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    '$completedSessions ✓',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.1,
                                      color: habitColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const SizedBox.shrink(),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // Section 2: "Pola yang membutuhkan perhatian"
              const Text(
                'POLA YANG MEMBUTUHKAN PERHATIAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppPalette.textDim,
                ),
              ),
              const SizedBox(height: 12),

              awarenessAsync.when(
                data: (stats) {
                  final neglected = stats.neglectedHabits;
                  if (neglected.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPalette.appleSuccessGlass,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppPalette.appleSuccessBorder,
                          width: 0.5,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppPalette.appleSuccess, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Semua kebiasaan berjalan dengan ritme yang stabil minggu ini. Pertahankan ketenanganmu.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppPalette.text,
                                height: 1.45,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: neglected.map((h) {
                      final missedCount = stats.habitMissedCounts[h.id] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppPalette.appleGlassBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppPalette.appleGlassBorder,
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
                            Text(h.iconKey, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: AppPalette.text,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    missedCount > 0
                                        ? '$missedCount kali terlewati belakangan ini. Sadari tanpa menghakimi diri.'
                                        : 'Belum sering dilakukan. Apakah ini masih penting bagimu?',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppPalette.textDim,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
