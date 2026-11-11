import 'package:flutter_test/flutter_test.dart';
import 'package:sadar/services/deep_link_service.dart';
import 'package:sadar/services/focus_session_contract.dart';

void main() {
  test('Sadar timer link matches Focus Clock v1 contract', () {
    final params = TimerLaunchParams(
      habitId: 41,
      title: 'Study LKS',
      durationMinutes: 35,
      callbackUrl: 'sadar://completed',
    );

    final uri = params.toUri();
    final request = FocusSessionContract.parseFocusClockUri(uri);
    final restored = TimerLaunchParams.fromUri(uri);

    expect(uri.queryParameters['version'], 'v1');
    expect(uri.queryParameters['timestamp'], isNotEmpty);
    expect(request?.habitId, 41);
    expect(request?.targetMinutes, 35);
    expect(restored?.title, 'Study LKS');
  });
}
