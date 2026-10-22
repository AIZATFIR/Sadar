import 'package:flutter_test/flutter_test.dart';
import 'package:sadar/core/time_math.dart';
import 'package:sadar/data/repositories/activity_repository.dart';
import 'package:sadar/data/repositories/blueprint_repository.dart';
import 'package:sadar/models/routine_blueprint.dart';
import 'package:sadar/services/blueprint_applier_service.dart';
import 'package:sadar/services/notification_service.dart';

void main() {
  group('BlueprintApplierService & BlueprintRepository', () {
    test('BlueprintRepository returns official blueprints and allows custom adding', () {
      final repo = BlueprintRepository();
      final all = repo.getAll();
      expect(all.length, greaterThanOrEqualTo(2));
      expect(all.any((b) => b.id == 101), isTrue);
      expect(all.any((b) => b.id == 102), isTrue);

      final custom = RoutineBlueprint(
        id: 999,
        name: 'My Custom Sprint Day',
        tagline: 'Deep coding day',
        description: 'No meetings',
        author: 'User',
        category: 'Focus',
        iconKey: '🚀',
        blocks: [
          const BlueprintBlock(
            title: 'Coding Sprint',
            startMinute: 0,
            endMinute: 180,
            ampmHalf: AmPmHalf.am,
            iconKey: '💻',
            colorValue: 0xFF3B82F6,
            philosophy: 'Code all morning',
            category: 'Deepwork',
          ),
        ],
      );

      repo.save(custom);
      expect(repo.getAll().any((b) => b.id == 999), isTrue);
    });

    test('BlueprintApplierService converts blueprint blocks into Activity entries', () async {
      final activityRepo = ActivityRepository(null, NotificationService());
      final service = BlueprintApplierService(activityRepo);

      final blueprint = RoutineBlueprint.muslimFivePillars();
      final date = DateTime(2026, 8, 21);

      final count = await service.applyBlueprint(
        blueprint: blueprint,
        targetDate: date,
        isDailyRecurring: true,
      );

      expect(count, equals(blueprint.blocks.length));
    });
  });
}
