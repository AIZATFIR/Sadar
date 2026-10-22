import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/future_self.dart';

class FutureSelfBridgeService {
  static const MethodChannel _channel = MethodChannel('com.aizatfir.sadar/widget');

  /// Updates the native home screen widget with the latest snapshot
  static Future<bool> updateNativeWidget(FutureSelfSnapshot snapshot) async {
    if (kIsWeb) return false;
    try {
      final jsonString = jsonEncode(snapshot.toJson());
      final result = await _channel.invokeMethod<bool>('updateWidget', {
        'snapshotJson': jsonString,
      });
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FutureSelfBridgeService.updateNativeWidget error: $e');
      }
      return false;
    }
  }

  /// Updates or cancels the low-cortisol lockscreen glance notification
  static Future<bool> updateLockscreenGlance({
    required bool enabled,
    required String goal,
    required String ratio,
    required String details,
  }) async {
    if (kIsWeb) return false;
    try {
      final result = await _channel.invokeMethod<bool>('updateLockscreenGlance', {
        'enabled': enabled,
        'goal': goal,
        'ratio': ratio,
        'details': details,
      });
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FutureSelfBridgeService.updateLockscreenGlance error: $e');
      }
      return false;
    }
  }

  /// Convenience method to sync both AppWidget and lockscreen glance
  static Future<void> syncSnapshot(
    FutureSelfSnapshot snapshot, {
    bool syncLockscreen = true,
  }) async {
    await updateNativeWidget(snapshot);

    if (syncLockscreen) {
      final details = snapshot.completedActivities == snapshot.totalActivities && snapshot.totalActivities > 0
          ? 'Semua aktivitas selesai'
          : '${snapshot.completedActivities} selesai hari ini';

      await updateLockscreenGlance(
        enabled: true,
        goal: snapshot.futureSelfGoal,
        ratio: '${snapshot.completedActivities}/${snapshot.totalActivities}',
        details: details,
      );
    }
  }
}

/// Provider for FutureSelfBridgeService
final futureSelfBridgeServiceProvider = Provider<FutureSelfBridgeService>((ref) {
  return FutureSelfBridgeService();
});
