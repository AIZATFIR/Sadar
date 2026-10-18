import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../models/daily_reflection.dart';
import '../../../providers/sadar_providers.dart';

class ReflectionSheet extends ConsumerStatefulWidget {
  const ReflectionSheet({
    super.key,
    required this.dateString,
    this.existingReflection,
    required this.onSaved,
  });

  final String dateString;
  final DailyReflection? existingReflection;
  final VoidCallback onSaved;

  @override
  ConsumerState<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends ConsumerState<ReflectionSheet> {
  late ReflectionFeeling _feeling;
  late TextEditingController _proudCtrl;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReflection;
    _feeling = r?.feeling ?? ReflectionFeeling.good;
    _proudCtrl = TextEditingController(text: r?.proudOfToday ?? '');
    _noteCtrl = TextEditingController(text: r?.note ?? '');
  }

  @override
  void dispose() {
    _proudCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    final reflection = widget.existingReflection ?? DailyReflection()
      ..dateString = widget.dateString;

    reflection.feeling = _feeling;
    reflection.proudOfToday = _proudCtrl.text.trim();
    reflection.note = _noteCtrl.text.trim();

    await ref.read(sadarRepoProvider).saveDailyReflection(reflection);
    // Invalidate provider so UI updates immediately
    ref.invalidate(dailyReflectionProvider(widget.dateString));
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: AppPalette.appleGlassBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(
              top: BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // iOS Drag Handle
                Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppPalette.accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppPalette.accent.withValues(alpha: 0.35),
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.spa_rounded, color: AppPalette.accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Today's Reflection",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppPalette.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Did you do what mattered to you today?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppPalette.textDim,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 24),

                // 1. Feeling Option Chips
                const Text(
                  'HOW DO YOU FEEL ABOUT TODAY?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppPalette.textDim,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _feelingChip(ReflectionFeeling.notSatisfied, '🌧️', 'Reflecting'),
                    const SizedBox(width: 8),
                    _feelingChip(ReflectionFeeling.okay, '☁️', 'Okay'),
                    const SizedBox(width: 8),
                    _feelingChip(ReflectionFeeling.good, '🌿', 'Good'),
                    const SizedBox(width: 8),
                    _feelingChip(ReflectionFeeling.proud, '🌟', 'Proud'),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. Proud of Today Concept
                const Text(
                  'TODAY I AM PROUD THAT...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppPalette.accent,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What did you do today that you are glad you did?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.textDim,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _proudCtrl,
                  style: const TextStyle(fontSize: 14, color: AppPalette.text, letterSpacing: -0.1),
                  decoration: InputDecoration(
                    hintText: 'misal: Aku belajar bahasa walau awalnya terasa lelah.',
                    hintStyle: const TextStyle(color: AppPalette.textDim, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppPalette.accent, width: 1.2),
                    ),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 18),

                // 3. Optional Reflection Note
                const Text(
                  'OPTIONAL NOTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppPalette.textDim,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  style: const TextStyle(fontSize: 13, color: AppPalette.text, letterSpacing: -0.1),
                  decoration: InputDecoration(
                    hintText: 'Catatan tambahan tentang hari ini...',
                    hintStyle: const TextStyle(color: AppPalette.textDim, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppPalette.accent, width: 1.2),
                    ),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 28),

                // Submit Button
                ApplePressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppPalette.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Reflection',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feelingChip(ReflectionFeeling feeling, String emoji, String label) {
    final isSelected = _feeling == feeling;
    return Expanded(
      child: ApplePressable(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _feeling = feeling);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppPalette.accent.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppPalette.accent
                  : AppPalette.appleGlassBorder,
              width: isSelected ? 1.5 : 0.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppPalette.accent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                  color: isSelected ? AppPalette.accent : AppPalette.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
