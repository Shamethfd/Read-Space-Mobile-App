import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:read_space/main.dart';
import 'package:read_space/pages/seat_booking_flow.dart';

void main() {
  testWidgets('ReadSpace app launches to splash and onboarding flow', (
    tester,
  ) async {
    await tester.pumpWidget(const ReadSpaceApp());

    expect(find.byType(ReadSpaceLogo), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump();
    expect(
      find.text('Welcome to ReadSpace — your smart library companion.'),
      findsOneWidget,
    );
  });

  testWidgets('seat booking map renders its interactive content', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SeatBookingFlow()));
    await tester.pumpAndSettle();

    expect(find.byType(SeatBookingFlow), findsOneWidget);
    expect(find.text('Near Power Outlet', skipOffstage: false), findsOneWidget);
    expect(find.text('A-01', skipOffstage: false), findsOneWidget);
    expect(find.text('MAIN ENTRANCE', skipOffstage: false), findsOneWidget);
  });
}
