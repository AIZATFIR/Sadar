import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../models/habit.dart';
import '../../../providers/sadar_providers.dart';
import 'allowed_apps_selector_dialog.dart';
import 'progression_editor_dialog.dart';

class HabitEditorSheet extends ConsumerStatefulWidget {
  const HabitEditorSheet({
    super.key,
    this.habit,
    required this.onSaved,
  });

  final Habit? habit;
  final VoidCallback onSaved;

  @override
  ConsumerState<HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends ConsumerState<HabitEditorSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _hybridSetsCtrl;
  late TextEditingController _hybridSecsCtrl;
  late String _selectedIcon;
  late HabitUnit _selectedUnit;
  late String _habitType; // 'timed' | 'count' | 'progression' | 'hybrid'
  late List<String> _allowedPackages;
  late List<ProgressionStep> _progressionSteps;
  late int _selectedColor;

  static const List<String> _popularIcons = [
    '📖', '💻', '🏋️', '🏃', '🇫🇷', '🧘', '📚', '✍️', '💧', '🥗', '🎯', '⚡'
  ];

  static const List<int> _colorOptions = [
    0xFF10B981, // Emerald
    0xFF3B82F6, // Blue
    0xFFF59E0B, // Amber
    0xFFF97316, // Orange
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF06B6D4, // Cyan
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _targetCtrl = TextEditingController(text: (h?.target ?? 20).toString());
    _hybridSetsCtrl = TextEditingController(text: (h?.hybridSets ?? 3).toString());
    _hybridSecsCtrl = TextEditingController(text: (h?.hybridDurationSeconds ?? 60).toString());
    _selectedIcon = h?.iconKey.isNotEmpty == true ? h!.iconKey : '🎯';
    _selectedUnit = h?.unit ?? HabitUnit.min;
    _habitType = h?.effectiveHabitType ?? 'timed';
    _allowedPackages = List.from(h?.allowedPackages ?? []);
    _progressionSteps = List.from(h?.progressionSteps ?? defaultBodybuildingSteps);
    _selectedColor = h?.colorValue ?? _colorOptions[0];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _hybridSetsCtrl.dispose();
    _hybridSecsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final target = int.tryParse(_targetCtrl.text.trim()) ?? 20;
    final hybridSets = int.tryParse(_hybridSetsCtrl.text.trim()) ?? 3;
    final hybridSecs = int.tryParse(_hybridSecsCtrl.text.trim()) ?? 60;

    final habit = widget.habit ?? Habit();
    habit.name = name;
    habit.iconKey = _selectedIcon;
    habit.target = target.clamp(1, 9999);
    habit.unit = _selectedUnit;
    habit.habitType = _habitType;
    habit.timerEnabled = _habitType == 'timed' || _habitType == 'hybrid';
    habit.allowedPackages = _allowedPackages;
    habit.progressionPlanJson = jsonEncode(_progressionSteps.map((s) => s.toJson()).toList());
    habit.hybridSets = hybridSets.clamp(1, 100);
    habit.hybridDurationSeconds = hybridSecs.clamp(5, 3600);
    habit.colorValue = _selectedColor;
    if (widget.habit == null) {
      habit.createdAt = DateTime.now();
    }

    HapticFeedback.mediumImpact();
    await ref.read(sadarRepoProvider).upsertHabit(habit);
    widget.onSaved();
  }

  Future<void> _delete() async {
    if (widget.habit == null) return;
    HapticFeedback.heavyImpact();
    await ref.read(sadarRepoProvider).deleteHabit(widget.habit!.id);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;

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
                // iOS Grab Handle
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
                const SizedBox(height: 16),

                // Title & Action Header
                Row(
                  children: [
                    Text(
                      isEditing ? 'Ubah Kebiasaan' : 'Kebiasaan Bermakna Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppPalette.text,
                      ),
                    ),
                    const Spacer(),
                    if (isEditing)
                      ApplePressable(
                        onTap: _delete,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 19,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Habit Name Input
                TextField(
                  controller: _nameCtrl,
                  autofocus: !isEditing,
                  style: const TextStyle(fontSize: 15, color: AppPalette.text, letterSpacing: -0.2),
                  decoration: InputDecoration(
                    labelText: 'Nama Kebiasaan',
                    hintText: 'misal: Deep Work, Olahraga, Belajar Bahasa, Membaca',
                    labelStyle: const TextStyle(color: AppPalette.textDim, fontSize: 13),
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
                ),
                const SizedBox(height: 18),

                // Emoji Picker Row
                const Text(
                  'PILIH SIMBOL / EMOJI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppPalette.textDim,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularIcons.map((icon) {
                    final isSelected = _selectedIcon == icon;
                    return ApplePressable(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIcon = icon);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppPalette.accent.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppPalette.accent : AppPalette.appleGlassBorder,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppPalette.accent.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    spreadRadius: 0.5,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(icon, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Tipe Kebiasaan Selector (iOS Segmented Pill Bar)
                const Text(
                  'TIPE KEBIASAAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppPalette.textDim,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.appleGlassBorder, width: 0.5),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeChip('timed', '⏱️ Timed (YPT)'),
                        const SizedBox(width: 4),
                        _buildTypeChip('count', '🔢 Count'),
                        const SizedBox(width: 4),
                        _buildTypeChip('progression', '🏋️ Bodybuilding'),
                        const SizedBox(width: 4),
                        _buildTypeChip('hybrid', '⚡ Hybrid'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // DYNAMIC SECTION BASED ON TYPE
                if (_habitType == 'timed') ...[
                  // Timed (YPT Focus)
                  TextField(
                    controller: _targetCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, color: AppPalette.text),
                    decoration: InputDecoration(
                      labelText: 'Durasi Fokus (Menit)',
                      labelStyle: const TextStyle(color: AppPalette.textDim),
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
                  ),
                  const SizedBox(height: 12),
                  // Whitelist button
                  ApplePressable(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AllowedAppsSelectorDialog(
                          initialAllowed: _allowedPackages,
                          onSaved: (packages) {
                            setState(() => _allowedPackages = packages);
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppPalette.appleGlassBorder, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 18, color: AppPalette.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _allowedPackages.isEmpty
                                  ? 'Pilih Aplikasi Diizinkan (Whitelist: Belum Ada)'
                                  : '${_allowedPackages.length} Aplikasi Diizinkan selama Fokus',
                              style: const TextStyle(fontSize: 13, color: Colors.white, letterSpacing: -0.1),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),
                ] else if (_habitType == 'count') ...[
                  // Count Mode
                  TextField(
                    controller: _targetCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, color: AppPalette.text),
                    decoration: InputDecoration(
                      labelText: 'Target Jumlah / Repetisi',
                      hintText: 'misal: 1 untuk course/kegiatan harian, 20 untuk push up',
                      labelStyle: const TextStyle(color: AppPalette.textDim),
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
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Cocok untuk target repetisi, 1 course Kalaam, atau checklist kegiatan harian.',
                    style: TextStyle(fontSize: 11, color: AppPalette.textDim, letterSpacing: -0.1),
                  ),
                ] else if (_habitType == 'progression') ...[
                  // Progression / Bodybuilding Mode
                  ApplePressable(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ProgressionEditorDialog(
                          initialSteps: _progressionSteps,
                          onSaved: (steps) {
                            setState(() => _progressionSteps = steps);
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppPalette.accent.withValues(alpha: 0.4), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center_rounded, size: 20, color: AppPalette.accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Konfigurasi Jadwal Mingguan (${_progressionSteps.length} Hari)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.1,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Target tidak berubah jika hari ini belum di-accomplish.',
                                  style: TextStyle(fontSize: 11, color: AppPalette.textDim, letterSpacing: -0.1),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_note_rounded, size: 20, color: AppPalette.accent),
                        ],
                      ),
                    ),
                  ),
                ] else if (_habitType == 'hybrid') ...[
                  // Hybrid Mode (Set x Duration)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hybridSetsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, color: AppPalette.text),
                          decoration: InputDecoration(
                            labelText: 'Jumlah Set',
                            hintText: '3',
                            labelStyle: const TextStyle(color: AppPalette.textDim),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _hybridSecsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, color: AppPalette.text),
                          decoration: InputDecoration(
                            labelText: 'Detik per Set',
                            hintText: '60',
                            labelStyle: const TextStyle(color: AppPalette.textDim),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kombinasi Repetisi Set x Timer. Contoh: Plank 3 set @ 60 detik.',
                    style: TextStyle(fontSize: 11, color: AppPalette.textDim, letterSpacing: -0.1),
                  ),
                ],
                const SizedBox(height: 20),

                // Color Accent Selection
                const Text(
                  'WARNA TAG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppPalette.textDim,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _colorOptions.map((c) {
                    final isSelected = _selectedColor == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ApplePressable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedColor = c);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(c).withValues(alpha: 0.55),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Apple Save Action Button
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
                    child: Text(
                      isEditing ? 'Simpan Perubahan' : 'Buat Kebiasaan',
                      style: const TextStyle(
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

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _habitType == type;
    return ApplePressable(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _habitType = type);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppPalette.accent.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppPalette.accent.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: -0.2,
            color: isSelected ? AppPalette.accent : AppPalette.textDim,
          ),
        ),
      ),
    );
  }
}
