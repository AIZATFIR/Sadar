import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../providers/sadar_providers.dart';

class DailyFulfillmentBanner extends ConsumerWidget {
  const DailyFulfillmentBanner({
    super.key,
    required this.selectedDate,
    required this.onToggleAwareness,
    required this.isShowingAwareness,
  });

  final DateTime selectedDate;
  final VoidCallback onToggleAwareness;
  final bool isShowingAwareness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final y = selectedDate.year.toString().padLeft(4, '0');
    final m = selectedDate.month.toString().padLeft(2, '0');
    final d = selectedDate.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';

    final fulfillmentAsync = ref.watch(dailyFulfillmentProvider(dateStr));
    final dateFormatted = DateFormat('EEEE, d MMMM').format(selectedDate);

    final isToday = _isSameDay(selectedDate, DateTime.now());

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
              // Row: Date & Action Switcher
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                dateFormatted,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppPalette.text,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppPalette.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppPalette.accent.withValues(alpha: 0.4),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Text(
                                  'HARI INI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppPalette.accent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '"Did I live today in a way I can be proud of?"',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppPalette.textDim,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Awareness Toggle Button with Apple tactile feedback
                  ApplePressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onToggleAwareness();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Tooltip(
                      message: isShowingAwareness ? 'Tutup Pola Kesadaran' : 'Lihat Pola Kesadaran',
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isShowingAwareness
                              ? AppPalette.accent.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isShowingAwareness
                                ? AppPalette.accent.withValues(alpha: 0.4)
                                : AppPalette.appleGlassBorder,
                            width: 0.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isShowingAwareness ? Icons.calendar_view_week_rounded : Icons.insights_rounded,
                          size: 19,
                          color: isShowingAwareness ? AppPalette.accent : AppPalette.textDim,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Fulfillment Progress Track
              fulfillmentAsync.when(
                data: (summary) {
                  final ratio = summary.ratio;
                  final completed = summary.completedCount;
                  final total = summary.totalCount;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            total > 0
                                ? '$completed / $total tindakan bermakna terlaksana'
                                : 'Belum ada kebiasaan yang terdaftar',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppPalette.text,
                            ),
                          ),
                          Text(
                            summary.isFulfilled
                                ? 'Hari Terpenuhi 🌿'
                                : (completed > 0 ? 'Membangun Hari' : 'Mulai dari satu aksi'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                              color: summary.isFulfilled ? AppPalette.appleSuccess : AppPalette.textDim,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 7,
                          color: Colors.white.withValues(alpha: 0.06),
                          child: LinearProgressIndicator(
                            value: total > 0 ? ratio : 0.0,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              summary.isFulfilled ? AppPalette.appleSuccess : AppPalette.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
