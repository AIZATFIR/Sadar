import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/habit.dart';
import '../../providers/sadar_providers.dart';
import '../../services/sadar_timer_engine.dart';
import '../../services/secure_storage_service.dart';
import 'widgets/awareness_view.dart';
import 'widgets/daily_fulfillment_banner.dart';
import 'widgets/desktop_floating_timer.dart';
import 'widgets/habit_editor_sheet.dart';
import 'widgets/horizontal_timeline_grid.dart';
import 'widgets/onboarding_view.dart';
import 'widgets/today_view.dart';
import 'widgets/what_i_repeat_view.dart';

class SadarHomeScreen extends ConsumerStatefulWidget {
  const SadarHomeScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  ConsumerState<SadarHomeScreen> createState() => _SadarHomeScreenState();
}

class _SadarHomeScreenState extends ConsumerState<SadarHomeScreen> {
  int _currentTabIndex = 0;
  bool? _isOnboardingDone;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final done = await ref.read(secureStorageServiceProvider).isSadarOnboardingDone();
      if (mounted) {
        setState(() => _isOnboardingDone = done);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isOnboardingDone = true);
      }
    }
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

  void _showPhilosophyDialog() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppPalette.appleGlassBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppPalette.appleGlassBorder,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppPalette.accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppPalette.accent.withValues(alpha: 0.35),
                                width: 0.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.spa_rounded, color: AppPalette.accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filosofi Sadar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: AppPalette.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppPalette.appleGlassBorder,
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          '“Until you make the unconscious conscious, it will direct your life and you will call it fate.”',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: AppPalette.text,
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Sadar bukan sekadar pelacak kebiasaan, melainkan kompas kesadaran harian.\n\n'
                        'Pertanyaannya bukan: "Seberapa produktif saya?"\n'
                        'Melainkan: "Apakah saya menjalani hari ini dengan cara yang bisa saya hargai?"\n\n'
                        '• Kesadaran: Apa yang tidak kau sadari akan mengarahkan hidupmu.\n'
                        '• Pengulangan: Apa yang berulang kali kau lakukan membentuk dirimu.\n'
                        '• Pemenuhan Diri: Menepati janji pada diri sendiri.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppPalette.textDim,
                          height: 1.5,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              setState(() => _isOnboardingDone = false);
                            },
                            child: const Text(
                              'Buka Panduan',
                              style: TextStyle(
                                color: AppPalette.textDim,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ApplePressable(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppPalette.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Saya Mengerti',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final selectedDate = ref.watch(sadarSelectedDateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DailyFulfillmentBanner(
                selectedDate: selectedDate,
                isShowingAwareness: false,
                onToggleAwareness: () {
                  setState(() => _currentTabIndex = 3);
                },
              ),
              const SizedBox(height: 16),
              habitsAsync.when(
                data: (habits) => HorizontalTimelineGrid(
                  habits: habits,
                  onEditHabit: (h) => _openHabitEditor(h),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Error: $err', style: const TextStyle(color: Color(0xFFEF4444))),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double size = 20,
    bool isAccent = false,
  }) {
    return ApplePressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isAccent
                ? AppPalette.accent.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAccent
                  ? AppPalette.accent.withValues(alpha: 0.35)
                  : AppPalette.appleGlassBorder,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size,
            color: isAccent ? AppPalette.accent : AppPalette.textDim,
          ),
        ),
      ),
    );
  }

  Widget _buildPillTabItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: ApplePressable(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentTabIndex = index);
        },
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppPalette.appleGlassPillActive
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: isSelected
                ? Border.all(color: AppPalette.accent.withValues(alpha: 0.32), width: 0.5)
                : Border.all(color: Colors.transparent, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? AppPalette.accent : AppPalette.textDim,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                  color: isSelected ? AppPalette.text : AppPalette.textDim,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Desktop Floating Timer Mode check
    final isFloating = ref.watch(timerEngineProvider.select((s) => s.isFloating));
    if (isFloating) {
      return const DesktopFloatingTimer();
    }

    // 2. First Launch Onboarding Check
    if (_isOnboardingDone == false) {
      return OnboardingView(
        onComplete: () async {
          await ref.read(secureStorageServiceProvider).setSadarOnboardingDone(true);
          if (mounted) {
            setState(() => _isOnboardingDone = true);
          }
        },
      );
    }

    if (_isOnboardingDone == null) {
      return const Scaffold(
        backgroundColor: AppPalette.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3. Main Multi-Screen Tab Interface
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: const BoxDecoration(
                color: AppPalette.appleGlassPillBg,
                border: Border(
                  bottom: BorderSide(
                    color: AppPalette.appleGlassBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (widget.onBack != null)
                            _buildHeaderIconButton(
                              icon: Icons.chevron_left_rounded,
                              tooltip: 'Kembali',
                              onTap: widget.onBack!,
                              size: 24,
                            )
                          else
                            const SizedBox(width: 36),
                          const Spacer(),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SADAR',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.0,
                                  color: AppPalette.text,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'WAY OF LIFE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                  color: AppPalette.textDim,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildHeaderIconButton(
                            icon: Icons.info_outline_rounded,
                            tooltip: 'Filosofi Sadar',
                            onTap: _showPhilosophyDialog,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderIconButton(
                            icon: Icons.add_rounded,
                            tooltip: 'Tambah Kebiasaan',
                            onTap: () => _openHabitEditor(),
                            size: 21,
                            isAccent: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            const TodayView(),
            _buildTimelineTab(),
            const WhatIRepeatView(),
            const AwarenessView(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Center(
            mainAxisSize: MainAxisSize.min,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppPalette.appleGlassPillBg,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppPalette.appleGlassBorder,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.32),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPillTabItem(
                          index: 0,
                          label: 'Hari Ini',
                          icon: Icons.wb_sunny_rounded,
                        ),
                        _buildPillTabItem(
                          index: 1,
                          label: 'Linimasa',
                          icon: Icons.calendar_view_week_rounded,
                        ),
                        _buildPillTabItem(
                          index: 2,
                          label: 'Repetisi',
                          icon: Icons.repeat_rounded,
                        ),
                        _buildPillTabItem(
                          index: 3,
                          label: 'Kesadaran',
                          icon: Icons.insights_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
