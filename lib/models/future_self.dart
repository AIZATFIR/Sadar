import 'habit.dart';

class FutureSelfActivityItem {
  final int id;
  final String title;
  final String iconKey;
  final int target;
  final HabitUnit unit;
  final String habitType;
  final int colorValue;
  final bool isCompleted;
  final int valueCompleted;
  final int actualDurationMinutes;
  final String? preferredTime;

  const FutureSelfActivityItem({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.target,
    this.unit = HabitUnit.min,
    this.habitType = 'timed',
    this.colorValue = 0xFFF0C987,
    required this.isCompleted,
    this.valueCompleted = 0,
    this.actualDurationMinutes = 0,
    this.preferredTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'iconKey': iconKey,
    'target': target,
    'unit': unit.name,
    'habitType': habitType,
    'colorValue': colorValue,
    'isCompleted': isCompleted,
    'valueCompleted': valueCompleted,
    'actualDurationMinutes': actualDurationMinutes,
    'preferredTime': preferredTime,
  };

  factory FutureSelfActivityItem.fromJson(Map<String, dynamic> json) => FutureSelfActivityItem(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    iconKey: json['iconKey'] as String? ?? '🎯',
    target: json['target'] as int? ?? 1,
    unit: HabitUnit.values.firstWhere(
      (u) => u.name == json['unit'],
      orElse: () => HabitUnit.min,
    ),
    habitType: json['habitType'] as String? ?? 'timed',
    colorValue: json['colorValue'] as int? ?? 0xFFF0C987,
    isCompleted: json['isCompleted'] as bool? ?? false,
    valueCompleted: json['valueCompleted'] as int? ?? 0,
    actualDurationMinutes: json['actualDurationMinutes'] as int? ?? 0,
    preferredTime: json['preferredTime'] as String?,
  );
}

class FutureSelfSnapshot {
  final String dateString;
  final String futureSelfGoal;
  final List<FutureSelfActivityItem> activities;
  final String? gratitudeSnippet;
  final List<String> gratitudeEntries;
  final DateTime updatedAt;

  const FutureSelfSnapshot({
    required this.dateString,
    required this.futureSelfGoal,
    required this.activities,
    this.gratitudeSnippet,
    this.gratitudeEntries = const [],
    required this.updatedAt,
  });

  int get totalActivities => activities.length;
  int get completedActivities => activities.where((a) => a.isCompleted).length;
  int get pendingActivities => totalActivities - completedActivities;
  double get completionRatio =>
      totalActivities > 0 ? (completedActivities / totalActivities).clamp(0.0, 1.0) : 0.0;
  bool get isFulfilled => totalActivities > 0 && completedActivities >= totalActivities;
  bool get isAllCompleted => isFulfilled;

  FutureSelfActivityItem? get nextActionableActivity =>
      activities.where((a) => !a.isCompleted).firstOrNull;

  Map<String, dynamic> toJson() => {
    'dateString': dateString,
    'futureSelfGoal': futureSelfGoal,
    'activities': activities.map((a) => a.toJson()).toList(),
    'gratitudeSnippet': gratitudeSnippet,
    'gratitudeEntries': gratitudeEntries,
    'updatedAt': updatedAt.toIso8601String(),
    'totalActivities': totalActivities,
    'completedActivities': completedActivities,
    'completionRatio': completionRatio,
  };

  factory FutureSelfSnapshot.fromJson(Map<String, dynamic> json) => FutureSelfSnapshot(
    dateString: json['dateString'] as String? ?? '',
    futureSelfGoal: json['futureSelfGoal'] as String? ?? 'Membangun kehidupan bermakna & sadar.',
    activities: (json['activities'] as List<dynamic>? ?? [])
        .map((e) => FutureSelfActivityItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    gratitudeSnippet: json['gratitudeSnippet'] as String?,
    gratitudeEntries: (json['gratitudeEntries'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
        : DateTime.now(),
  );

  static FutureSelfSnapshot empty(String dateString) => FutureSelfSnapshot(
    dateString: dateString,
    futureSelfGoal: 'Membangun kehidupan bermakna dengan disiplin & kesadaran.',
    activities: const [],
    gratitudeSnippet: null,
    gratitudeEntries: const [],
    updatedAt: DateTime.now(),
  );
}
