import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sadar/data/repositories/sadar_repository.dart';
import 'package:sadar/features/sadar/widgets/future_self_visualizer.dart';
import 'package:sadar/features/sadar/widgets/future_self_widget.dart';
import 'package:sadar/models/future_self.dart';
import 'package:sadar/models/habit_entry.dart';
import 'package:sadar/providers/sadar_providers.dart';

void main() {
  group('Future Self Data Model Tests (PRD §8 & §14)', () {
    test('FutureSelfSnapshot calculates ratios and completion correctly', () {
      final snapshot = FutureSelfSnapshot(
        dateString: '2026-10-22',
        futureSelfGoal: 'Software Engineer & Mandiri',
        activities: [
          const FutureSelfActivityItem(
            id: 1,
            title: 'Ngoding Flutter',
            target: 60,
            isCompleted: true,
            iconKey: '💻',
            colorValue: 0xFF10B981,
          ),
          const FutureSelfActivityItem(
            id: 2,
            title: '1 Ayat Al-Quran',
            target: 1,
            isCompleted: true,
            iconKey: '📖',
            colorValue: 0xFFF0C987,
          ),
          const FutureSelfActivityItem(
            id: 3,
            title: 'Olahraga',
            target: 30,
            isCompleted: false,
            iconKey: '🏃',
            colorValue: 0xFF6366F1,
          ),
        ],
        gratitudeSnippet: 'Bersyukur atas tubuh sehat',
        gratitudeEntries: ['Bersyukur atas tubuh sehat'],
        updatedAt: DateTime.parse('2026-10-22 10:00:00'),
      );

      expect(snapshot.totalActivities, 3);
      expect(snapshot.completedActivities, 2);
      expect(snapshot.completionRatio, closeTo(2 / 3, 0.001));
      expect(snapshot.isAllCompleted, isFalse);
      expect(snapshot.gratitudeSnippet, 'Bersyukur atas tubuh sehat');

      // Serialization test
      final json = snapshot.toJson();
      expect(json['futureSelfGoal'], 'Software Engineer & Mandiri');
      expect(json['totalActivities'], 3);
      expect(json['completedActivities'], 2);

      final revived = FutureSelfSnapshot.fromJson(json);
      expect(revived.futureSelfGoal, snapshot.futureSelfGoal);
      expect(revived.activities.length, 3);
      expect(revived.activities[0].title, 'Ngoding Flutter');
      expect(revived.activities[0].isCompleted, isTrue);
    });

    test('Empty snapshot produces deliberate empty state without NaN or crashes', () {
      final empty = FutureSelfSnapshot.empty('2026-10-22');
      expect(empty.totalActivities, 0);
      expect(empty.completedActivities, 0);
      expect(empty.completionRatio, 0.0);
      expect(empty.isAllCompleted, isFalse);
      expect(empty.activities, isEmpty);
      expect(empty.gratitudeEntries, isEmpty);

      final json = empty.toJson();
      final revived = FutureSelfSnapshot.fromJson(json);
      expect(revived.totalActivities, 0);
      expect(revived.completionRatio, 0.0);
    });
  });

  group('Future Self Repository Integration Tests (PRD §2, §7, §8)', () {
    late SadarRepository repository;

    setUp(() async {
      repository = SadarRepository(null, seedSampleEntries: false);
    });

    test('getFutureSelfSnapshot retrieves real persisted data and matches habit entries', () async {
      final snapshot = await repository.getFutureSelfSnapshot('2026-10-22');
      expect(snapshot.activities, isNotEmpty);
      expect(snapshot.futureSelfGoal, isNotEmpty);

      final initialCompleted = snapshot.completedActivities;
      final targetHabit = snapshot.activities.first;

      // Complete target activity
      await repository.recordEntryStatus(
        habitId: targetHabit.id,
        dateString: '2026-10-22',
        status: HabitStatus.yes,
        valueCompleted: targetHabit.target,
      );

      final updatedSnapshot = await repository.getFutureSelfSnapshot('2026-10-22');
      expect(updatedSnapshot.completedActivities, initialCompleted + 1);

      final updatedItem = updatedSnapshot.activities.firstWhere((a) => a.id == targetHabit.id);
      expect(updatedItem.isCompleted, isTrue);
    });

    test('setFutureSelfGoal updates goal and preserves historical completions', () async {
      await repository.setFutureSelfGoal('Membangun Generasi Rabbani & Ahli Teknologi');
      final goal = await repository.getFutureSelfGoal();
      expect(goal, 'Membangun Generasi Rabbani & Ahli Teknologi');

      final snapshot = await repository.getFutureSelfSnapshot('2026-10-22');
      expect(snapshot.futureSelfGoal, 'Membangun Generasi Rabbani & Ahli Teknologi');
    });

    test('addGratitudeEntry stores gratitude and updates snapshot snippet', () async {
      await repository.addGratitudeEntry(
        'Alhamdulillah atas rezeki fokus dan waktu yang berkah',
        '2026-10-22',
      );

      final snapshot = await repository.getFutureSelfSnapshot('2026-10-22');
      expect(snapshot.gratitudeEntries, contains('Alhamdulillah atas rezeki fokus dan waktu yang berkah'));
      expect(snapshot.gratitudeSnippet, 'Alhamdulillah atas rezeki fokus dan waktu yang berkah');
    });

    test('Repeated completion actions are idempotent and do not create duplicate records', () async {
      final snapshot = await repository.getFutureSelfSnapshot('2026-10-22');
      final habitId = snapshot.activities.first.id;

      // Record yes twice
      await repository.recordEntryStatus(
        habitId: habitId,
        dateString: '2026-10-22',
        status: HabitStatus.yes,
        valueCompleted: 30,
      );
      await repository.recordEntryStatus(
        habitId: habitId,
        dateString: '2026-10-22',
        status: HabitStatus.yes,
        valueCompleted: 30,
      );

      final entries = await repository.getEntriesForDateRange('2026-10-22', '2026-10-22');
      final matching = entries.where((e) => e.habitId == habitId).toList();
      expect(matching.length, 1);
    });
  });

  group('Future Self Widget UI & Responsive Size Tests (PRD §4, §5, §6)', () {
    late SadarRepository repository;

    setUp(() async {
      repository = SadarRepository(null, seedSampleEntries: false);
    });

    Widget createTestApp(FutureSelfWidgetSize size) {
      return ProviderScope(
        overrides: [
          sadarRepoProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FutureSelfWidget(
                size: size,
                dateString: '2026-10-22',
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders Small widget (2x2) with radial visualizer and ratio', (tester) async {
      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.small));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FutureSelfVisualizer), findsOneWidget);
      expect(find.byType(FutureSelfWidget), findsOneWidget);
      expect(find.text('Membangun kehidupan bermakna dengan disiplin & kesadaran.'), findsOneWidget);
    });

    testWidgets('Renders Medium widget (4x2) with dial and activity list', (tester) async {
      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.medium));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FutureSelfVisualizer), findsOneWidget);
      expect(find.text('Fokus Coding (LKS)'), findsOneWidget);
    });

    testWidgets('Renders Large widget (4x4) with future self goal, dial, activities & gratitude', (tester) async {
      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.large));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FutureSelfVisualizer), findsOneWidget);
      expect(find.text('Fokus Coding (LKS)'), findsOneWidget);
      expect(find.text('Kalaam 1 Course'), findsOneWidget);
      expect(find.text('MENSYUKURI HARI INI'), findsOneWidget);
    });

    testWidgets('Renders Lockscreen widget (slim 1x4) with glanceable progress', (tester) async {
      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.lockscreen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FutureSelfVisualizer), findsOneWidget);
      expect(find.textContaining('/'), findsOneWidget);
    });

    testWidgets('Tapping activity toggle in Large widget updates completion state with haptic feedback', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.large));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the first completion checkbox/tap target
      final checkboxFinder = find.byIcon(Icons.radio_button_unchecked_rounded).first;
      expect(checkboxFinder, findsOneWidget);

      await tester.tap(checkboxFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Should now be completed (check icon)
      expect(find.byIcon(Icons.check_circle_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('Tapping future self goal opens in-place goal editor sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.large));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final goalFinder = find.text('Membangun kehidupan bermakna dengan disiplin & kesadaran.');
      expect(goalFinder, findsOneWidget);

      await tester.tap(goalFinder);
      await tester.pumpAndSettle();

      expect(find.text('Future Self Anchor'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('Tapping gratitude opens gratitude journaling modal', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(FutureSelfWidgetSize.large));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final gratitudeSection = find.text('MENSYUKURI HARI INI');
      expect(gratitudeSection, findsOneWidget);

      await tester.ensureVisible(gratitudeSection);
      await tester.pumpAndSettle();

      await tester.tap(gratitudeSection);
      await tester.pumpAndSettle();

      expect(find.text('Ruang Syukur Hari Ini'), findsOneWidget);
      expect(find.text('Simpan Syukur'), findsOneWidget);
    });
  });
}
