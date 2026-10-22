import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sadar/features/sadar/widgets/future_self_widget.dart';
import 'package:sadar/features/sadar/widgets/today_view.dart';

void main() {
  testWidgets('TodayView renders habits and greetings correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TodayView(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FutureSelfWidget), findsOneWidget);
    expect(find.text('Fokus Coding (LKS)'), findsAtLeastNWidgets(1));
    expect(find.text('Kalaam 1 Course'), findsAtLeastNWidgets(1));
  });
}
