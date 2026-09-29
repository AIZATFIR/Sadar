import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_clock/features/sadar/sadar_home_screen.dart';
import 'package:focus_clock/services/secure_storage_service.dart';

class MockSecureStorage extends SecureStorageService {
  @override
  Future<bool> isSadarOnboardingDone() async => true;
}

void main() {
  testWidgets('SadarHomeScreen mobile screen constraint verification', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    FlutterErrorDetails? caught;
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      caught = details;
      debugPrint('OVERFLOW DETAIL:\n${details.toString()}');
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(MockSecureStorage()),
        ],
        child: const MaterialApp(
          home: SadarHomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = oldHandler;

    expect(caught, isNull);
    expect(find.text('SADAR'), findsOneWidget);
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('Linimasa'), findsOneWidget);
    expect(find.text('Repetisi'), findsOneWidget);
    expect(find.text('Kesadaran'), findsOneWidget);
  });
}
