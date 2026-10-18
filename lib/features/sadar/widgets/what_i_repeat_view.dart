import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../providers/sadar_providers.dart';

class WhatIRepeatView extends ConsumerWidget {
  const WhatIRepeatView({super.key});

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repeatStatsAsync = ref.watch(whatIRepeatProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Apple Frosted Header Card
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
                              child: const Icon(Icons.repeat_rounded, color: AppPalette.accent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'WHAT YOU REPEAT',
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
                          '“We are what we repeatedly do.”',
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppPalette.text,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Satu sesi tampak kecil. Ratusan sesi yang diulang menjadi pola hidupmu yang sesungguhnya.',
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

              const Text(
                'AKUMULASI BUKTI HIDUP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppPalette.textDim,
                ),
              ),
              const SizedBox(height: 12),

              repeatStatsAsync.when(
                data: (stats) {
                  if (stats.isEmpty) {
                    return const Text(
                      'Belum ada repetisi yang tercatat.',
                      style: TextStyle(color: AppPalette.textDim, fontSize: 13),
                    );
                  }

                  // Find max days to normalize progress bar
                  final maxDays = stats.fold<int>(1, (maxVal, s) => max(maxVal, s.totalDays));

                  return Column(
                    children: stats.map((stat) {
                      final habit = stat.habit;
                      final habitColor = Color(habit.colorValue);
                      final ratio = maxDays > 0 ? (stat.totalDays / maxDays).clamp(0.05, 1.0) : 0.05;

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(habit.iconKey, style: const TextStyle(fontSize: 19)),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: AppPalette.text,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: habitColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: habitColor.withValues(alpha: 0.35),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    '${stat.totalDays} hari',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.1,
                                      color: habitColor,
                                    ),
                                  ),
                                ),
                                if (stat.totalMinutes > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${_formatDuration(stat.totalMinutes)})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppPalette.textDim,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 7,
                                color: Colors.white.withValues(alpha: 0.05),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation(habitColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err', style: const TextStyle(color: Color(0xFFEF4444))),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
