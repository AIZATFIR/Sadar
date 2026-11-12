import 'package:flutter_test/flutter_test.dart';
import 'package:sadar/services/deep_link_service.dart';
import 'package:sadar/services/focus_session_contract.dart';

void main() {
  test('web timer launch carries the Sadar completion callback', () {
    final uri = DeepLinkService.buildFocusClockWebTimerUri(
      habitId: 41,
      title: 'Study LKS',
      durationMinutes: 35,
      callbackUri: Uri.https('sadar-web.vercel.app', '/'),
    );
    final params = uri.queryParameters;

    expect(uri.host, 'focus-clock-web.vercel.app');
    expect(params['task'], 'Study LKS');
    expect(params['duration'], '35');
    expect(params['autoStart'], 'true');
    expect(params['habitId'], '41');
    expect(params['sessionId'], matches(RegExp(r'^[A-Za-z0-9._:-]{1,128}$')));
    expect(
      FocusSessionContract.isAllowedSadarWebCallback(
        Uri.parse(params['callback']!),
      ),
      isTrue,
    );
  });

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
