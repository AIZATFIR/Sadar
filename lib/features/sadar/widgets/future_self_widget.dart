import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/future_self.dart';
import '../../../models/habit_entry.dart';
import '../../../providers/sadar_providers.dart';
import '../../../services/focus_session_contract.dart';
import 'future_self_visualizer.dart';

enum FutureSelfWidgetSize {
  small,
  medium,
  large,
  lockscreen,
}

class FutureSelfWidget extends ConsumerWidget {
  const FutureSelfWidget({
    super.key,
    this.size = FutureSelfWidgetSize.large,
    this.dateString,
    this.onOpenFullApp,
  });

  final FutureSelfWidgetSize size;
  final String? dateString;
  final VoidCallback? onOpenFullApp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStr = dateString ?? _currentDateString();
    final snapshotAsync = ref.watch(futureSelfSnapshotStreamProvider(todayStr));

    return snapshotAsync.when(
      data: (snapshot) => _buildForSize(context, ref, snapshot),
      loading: () => _buildLoadingState(),
      error: (err, _) => _buildErrorState(context, ref, todayStr),
    );
  }

  static String _currentDateString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Widget _buildForSize(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    switch (size) {
      case FutureSelfWidgetSize.small:
        return _buildSmallWidget(context, ref, snapshot);
      case FutureSelfWidgetSize.medium:
        return _buildMediumWidget(context, ref, snapshot);
      case FutureSelfWidgetSize.large:
        return _buildLargeWidget(context, ref, snapshot);
      case FutureSelfWidgetSize.lockscreen:
        return _buildLockscreenWidget(context, ref, snapshot);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Small Widget (2x2): Compact dial + ratio + anchor
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSmallWidget(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.stroke, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureSelfVisualizer(
            snapshot: snapshot,
            size: 78,
            strokeWidth: 8,
            showCenterText: true,
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.futureSelfGoal,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppPalette.text,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Medium Widget (4x2): Left dial + Right top 3 activities with 1-tap toggles
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMediumWidget(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    final displayActivities = snapshot.activities.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.stroke, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Radial Dial Visualizer
          FutureSelfVisualizer(
            snapshot: snapshot,
            size: 96,
            strokeWidth: 9,
            showCenterText: true,
          ),
          const SizedBox(width: 16),
          // Right: Future Self Goal Anchor + Top activities
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: AppPalette.accent),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        snapshot.futureSelfGoal,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (displayActivities.isEmpty)
                  const Text(
                    'Belum ada kegiatan hari ini.',
                    style: TextStyle(fontSize: 12, color: AppPalette.textDim),
                  )
                else
                  ...displayActivities.map((act) => _buildCompactActivityRow(context, ref, snapshot.dateString, act)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActivityRow(
    BuildContext context,
    WidgetRef ref,
    String dateString,
    FutureSelfActivityItem act,
  ) {
    return InkWell(
      onTap: () => _toggleHabit(ref, act, dateString),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              act.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: act.isCompleted ? AppPalette.accent : AppPalette.outline,
            ),
            const SizedBox(width: 7),
            Text(act.iconKey, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                act.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: act.isCompleted ? FontWeight.w500 : FontWeight.w600,
                  color: act.isCompleted ? AppPalette.textDim : AppPalette.text,
                  decoration: act.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Large Widget (4x4): Full Card (Header, Visualizer, Activity List, Gratitude)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildLargeWidget(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: snapshot.isFulfilled
              ? AppPalette.accent.withValues(alpha: 0.4)
              : AppPalette.accent.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Future-Self Anchor Header (Editable)
          _buildFutureSelfHeader(context, ref, snapshot),
          const SizedBox(height: 16),

          // 2. Center Dial & Overview metrics
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureSelfVisualizer(
                snapshot: snapshot,
                size: 104,
                strokeWidth: 10,
                showCenterText: true,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.isFulfilled ? 'Hari Ini Terpenuhi' : 'Kehidupan yang Kamu Bangun',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: snapshot.isFulfilled
                            ? AppPalette.accent
                            : AppPalette.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.completedActivities} selesai dari ${snapshot.totalActivities} kegiatan nyata hari ini.',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppPalette.textDim,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: snapshot.completionRatio,
                      backgroundColor: AppPalette.stroke,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        snapshot.isFulfilled
                            ? AppPalette.accent
                            : AppPalette.accent,
                      ),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppPalette.stroke),
          const SizedBox(height: 14),

          // 3. Today's Activities List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KEGIATAN HARI INI',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppPalette.textDim,
                ),
              ),
              Text(
                '${snapshot.pendingActivities} tersisa',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppPalette.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (snapshot.activities.isEmpty)
            _buildEmptyActivitiesPrompt()
          else ...[
            _buildSketchActivityTiles(context, ref, snapshot.dateString, snapshot.activities),
            if (snapshot.activities.length > 3) ...[
              const SizedBox(height: 12),
              ...snapshot.activities.skip(3).map((act) => _buildLargeActivityItem(context, ref, snapshot.dateString, act)),
            ],
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppPalette.stroke),
          const SizedBox(height: 12),

          // 4. Gratitude Practice Bar (Mensyukuri)
          _buildGratitudeSection(context, ref, snapshot),
        ],
      ),
    );
  }

  Widget _buildFutureSelfHeader(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    return InkWell(
      onTap: () => _openGoalEditor(context, ref, snapshot.futureSelfGoal),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppPalette.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flag_rounded, size: 16, color: AppPalette.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FUTURE SELF ANCHOR',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: AppPalette.textDim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    snapshot.futureSelfGoal,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEDEDF2),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 16, color: AppPalette.textDim),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeActivityItem(
    BuildContext context,
    WidgetRef ref,
    String dateString,
    FutureSelfActivityItem act,
  ) {
    final isDone = act.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF131219) : AppPalette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? const Color(0xFF242330) : const Color(0xFF2C2B3B),
        ),
      ),
      child: Row(
        children: [
          // 1-tap Checkbox Toggle
          InkWell(
            onTap: () => _toggleHabit(ref, act, dateString),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: isDone ? AppPalette.accent : const Color(0xFF6B687C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(act.iconKey, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isDone ? FontWeight.w500 : FontWeight.w700,
                    color: isDone ? AppPalette.textDim : const Color(0xFFEDEDF2),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${act.target} ${act.unit.name}${act.preferredTime != null ? ' • ${act.preferredTime}' : ''}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppPalette.textDim,
                  ),
                ),
              ],
            ),
          ),
          // 1-tap Start Focus Timer Button (Focus Clock deep link)
          if (!isDone)
            InkWell(
              onTap: () => _launchFocusSession(context, act),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppPalette.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppPalette.accent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 14, color: AppPalette.accent),
                    SizedBox(width: 4),
                    Text(
                      'Timer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.accent,
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

  Widget _buildSketchActivityTiles(
    BuildContext context,
    WidgetRef ref,
    String dateString,
    List<FutureSelfActivityItem> activities,
  ) {
    final topThree = activities.take(3).toList();
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Row(
      children: topThree.map((act) {
        final isDone = act.isCompleted;

        return Expanded(
          child: InkWell(
            onTap: () => _toggleHabit(ref, act, dateString),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF131219) : const Color(0xFF1F1E29),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDone ? AppPalette.accent.withValues(alpha: 0.4) : const Color(0xFF2C2B3B),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(act.iconKey, style: const TextStyle(fontSize: 16)),
                      Icon(
                        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: isDone ? AppPalette.accent : const Color(0xFF6B687C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    act.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: isDone ? FontWeight.w500 : FontWeight.w700,
                      color: isDone ? AppPalette.textDim : const Color(0xFFEDEDF2),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${act.target} ${act.unit.name}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: AppPalette.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGratitudeSection(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    final hasGratitude = snapshot.gratitudeSnippet != null && snapshot.gratitudeSnippet!.isNotEmpty;

    return InkWell(
      onTap: () => _openGratitudeModal(context, ref, snapshot.dateString),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.volunteer_activism_outlined, size: 16, color: AppPalette.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MENSYUKURI HARI INI',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppPalette.textDim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasGratitude
                        ? snapshot.gratitudeSnippet!
                        : 'Tulis hal yang kamu syukuri hari ini...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: hasGratitude ? FontWeight.w600 : FontWeight.w500,
                      color: hasGratitude ? AppPalette.text : AppPalette.textDim,
                      fontStyle: hasGratitude ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppPalette.textDim),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Lock Screen Widget: Minimal single-strip glance
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildLockscreenWidget(
    BuildContext context,
    WidgetRef ref,
    FutureSelfSnapshot snapshot,
  ) {
    final next = snapshot.nextActionableActivity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F2D3D), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureSelfVisualizer(
            snapshot: snapshot,
            size: 26,
            strokeWidth: 4,
            showCenterText: false,
          ),
          const SizedBox(width: 8),
          Text(
            '${snapshot.completedActivities}/${snapshot.totalActivities}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppPalette.accent,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 14, color: const Color(0xFF333142)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              next != null ? '${next.iconKey} ${next.title}' : '✨ Semua Selesai',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEDEDF2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // State Handlers & Actions
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _toggleHabit(
    WidgetRef ref,
    FutureSelfActivityItem act,
    String dateString,
  ) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(sadarRepoProvider);
    final newStatus = act.isCompleted ? HabitStatus.unmarked : HabitStatus.yes;
    await repo.recordEntryStatus(
      habitId: act.id,
      dateString: dateString,
      status: newStatus,
      valueCompleted: newStatus == HabitStatus.yes ? act.target : 0,
    );
  }

  Future<void> _launchFocusSession(BuildContext context, FutureSelfActivityItem act) async {
    HapticFeedback.mediumImpact();
    final uri = FocusSessionContract.buildFocusClockUri(
      FocusSessionRequest(
        habitId: act.id,
        title: act.title,
        targetMinutes: act.target,
        requestedAt: DateTime.now(),
      ),
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web deployment with parameters
        final webUri = Uri.parse(
          'https://focus-clock-web.vercel.app/?task=${Uri.encodeComponent(act.title)}&duration=${act.target}&autoStart=true',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Membuka timer untuk ${act.title}')),
      );
    }
  }

  void _openGoalEditor(BuildContext context, WidgetRef ref, String currentGoal) {
    final controller = TextEditingController(text: currentGoal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Future Self Anchor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFEDEDF2)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tuliskan satu kalimat gambaran hidup yang sedang kamu bangun.',
                style: TextStyle(fontSize: 13, color: AppPalette.textDim),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 120,
                style: const TextStyle(color: Color(0xFFEDEDF2)),
                decoration: InputDecoration(
                  hintText: 'Contoh: Menjadi software engineer andal & berdisiplin',
                  hintStyle: const TextStyle(color: Color(0xFF6B687C)),
                  filled: true,
                  fillColor: const Color(0xFF131219),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF333142)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal', style: TextStyle(color: AppPalette.textDim)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppPalette.accent),
                    onPressed: () async {
                      final newGoal = controller.text.trim();
                      if (newGoal.isNotEmpty) {
                        await ref.read(sadarRepoProvider).setFutureSelfGoal(newGoal);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Simpan', style: TextStyle(color: Color(0xFF12100E), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGratitudeModal(BuildContext context, WidgetRef ref, String dateString) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.volunteer_activism_outlined, size: 20, color: AppPalette.accent),
                  SizedBox(width: 8),
                  Text(
                    'Ruang Syukur Hari Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFEDEDF2)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Mensyukuri apa yang sudah ada saat ini menenangkan hati sebelum mengejar apa yang belum tercapai.',
                style: TextStyle(fontSize: 13, color: AppPalette.textDim),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 2,
                maxLength: 140,
                style: const TextStyle(color: Color(0xFFEDEDF2)),
                decoration: InputDecoration(
                  hintText: 'Tulis hal yang kamu syukuri hari ini...',
                  hintStyle: const TextStyle(color: Color(0xFF6B687C)),
                  filled: true,
                  fillColor: const Color(0xFF131219),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF333142)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup', style: TextStyle(color: AppPalette.textDim)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppPalette.accent),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        await ref.read(sadarRepoProvider).addGratitudeEntry(text, dateString);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Simpan Syukur', style: TextStyle(color: Color(0xFF0F0E13), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyActivitiesPrompt() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14131A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Belum ada kegiatan yang dijadwalkan hari ini.',
          style: TextStyle(fontSize: 12, color: AppPalette.textDim),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppPalette.accent),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String todayStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppPalette.textDim),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Menyiapkan tampilan Future Self...',
              style: TextStyle(fontSize: 12, color: AppPalette.textDim),
            ),
          ),
          TextButton(
            onPressed: () => ref.refresh(futureSelfSnapshotStreamProvider(todayStr)),
            child: const Text('Muat Ulang', style: TextStyle(fontSize: 12, color: AppPalette.accent)),
          ),
        ],
      ),
    );
  }
}
