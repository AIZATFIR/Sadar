import 'package:flutter_test/flutter_test.dart';
import 'package:sadar/services/focus_session_contract.dart';

void main() {
  group('FocusSessionContract Tests (PRD 3 §2, §35, §84)', () {
    test('FocusSessionRequest JSON roundtrip', () {
      final req = FocusSessionRequest(
        habitId: 101,
        title: 'Deep Coding',
        targetMinutes: 45,
        requestedAt: DateTime(2026, 9, 11, 10, 30),
      );

      final json = req.toJson();
      expect(json['version'], 'v1');
      expect(json['habitId'], 101);
      expect(json['title'], 'Deep Coding');
      expect(json['targetMinutes'], 45);

      final restored = FocusSessionRequest.fromJson(json);
      expect(restored.habitId, req.habitId);
      expect(restored.title, req.title);
      expect(restored.targetMinutes, req.targetMinutes);
      expect(restored.requestedAt, req.requestedAt);
    });

    test('FocusSessionResult JSON roundtrip', () {
      final res = FocusSessionResult(
        sessionId: 'session-xyz-123',
        habitId: 101,
        startedAt: DateTime(2026, 9, 11, 10, 30),
        endedAt: DateTime(2026, 9, 11, 11, 15),
        actualDurationMinutes: 45,
        status: 'completed',
      );

      final json = res.toJson();
      expect(json['version'], 'v1');
      expect(json['sessionId'], 'session-xyz-123');
      expect(json['status'], 'completed');
      expect(res.isCompleted, true);

      final restored = FocusSessionResult.fromJson(json);
      expect(restored.sessionId, res.sessionId);
      expect(restored.habitId, res.habitId);
      expect(restored.actualDurationMinutes, 45);
      expect(restored.isCompleted, true);
    });

    test('buildFocusClockUri and parseFocusClockUri roundtrip', () {
      final req = FocusSessionRequest(
        habitId: 55,
        title: 'French Conversation',
        targetMinutes: 20,
        requestedAt: DateTime(2026, 9, 11, 14, 0),
        callbackUrl: 'sadar://completed',
      );

      final uri = FocusSessionContract.buildFocusClockUri(req);
      expect(uri.scheme, 'focusclock');
      expect(uri.host, 'timer');
      expect(uri.queryParameters['version'], 'v1');
      expect(uri.queryParameters['habitId'], '55');
      expect(uri.queryParameters['title'], 'French Conversation');
      expect(uri.queryParameters['minutes'], '20');

      final parsed = FocusSessionContract.parseFocusClockUri(uri);
      expect(parsed, isNotNull);
      expect(parsed!.habitId, 55);
      expect(parsed.title, 'French Conversation');
      expect(parsed.targetMinutes, 20);
      expect(parsed.callbackUrl, 'sadar://completed');
    });

    test('buildSadarCompletedUri and parseSadarCompletedUri roundtrip', () {
      final res = FocusSessionResult(
        sessionId: 'sess-888',
        habitId: 55,
        startedAt: DateTime(2026, 9, 11, 14, 0),
        endedAt: DateTime(2026, 9, 11, 14, 20),
        actualDurationMinutes: 20,
        status: 'completed',
      );

      final uri = FocusSessionContract.buildSadarCompletedUri(res);
      expect(uri.scheme, 'sadar');
      expect(uri.host, 'completed');
      expect(uri.queryParameters['sessionId'], 'sess-888');
      expect(uri.queryParameters['habitId'], '55');
      expect(uri.queryParameters['duration'], '20');
      expect(uri.queryParameters['status'], 'completed');

      final parsed = FocusSessionContract.parseSadarCompletedUri(uri);
      expect(parsed, isNotNull);
      expect(parsed!.sessionId, 'sess-888');
      expect(parsed.habitId, 55);
      expect(parsed.actualDurationMinutes, 20);
      expect(parsed.isCompleted, true);
    });

    test('parses a completion returned from Focus Clock web', () {
      final startedAt = DateTime(2026, 11, 12, 9);
      final endedAt = startedAt.add(const Duration(minutes: 25));
      final uri = Uri.https('sadar-web.vercel.app', '/', {
        'fc_version': '1',
        'fc_session': 'web-session-1',
        'fc_habit': '55',
        'fc_started': startedAt.millisecondsSinceEpoch.toString(),
        'fc_ended': endedAt.millisecondsSinceEpoch.toString(),
        'fc_duration': '25',
        'fc_status': 'completed',
      });

      final parsed = FocusSessionContract.parseSadarWebCompletedUri(uri);

      expect(parsed, isNotNull);
      expect(parsed!.sessionId, 'web-session-1');
      expect(parsed.habitId, 55);
      expect(parsed.actualDurationMinutes, 25);
      expect(parsed.isCompleted, isTrue);
    });

    test('rejects a web completion sent to another origin', () {
      final uri = Uri.https('evil.example', '/', {
        'fc_version': '1',
        'fc_session': 'web-session-1',
        'fc_habit': '55',
        'fc_started': '1794441600000',
        'fc_ended': '1794443100000',
        'fc_duration': '25',
        'fc_status': 'completed',
      });

      expect(FocusSessionContract.parseSadarWebCompletedUri(uri), isNull);
    });
  });
}
