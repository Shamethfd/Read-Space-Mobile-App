import 'package:flutter_test/flutter_test.dart';

import 'package:read_space/main.dart';

void main() {
  testWidgets('ReadSpace app launches to splash and onboarding flow', (tester) async {
    await tester.pumpWidget(const ReadSpaceApp());

    expect(find.byType(ReadSpaceLogo), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump();
    expect(find.text('Welcome to ReadSpace — your smart library companion.'), findsOneWidget);
  });
}
