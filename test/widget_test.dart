import 'package:flutter_test/flutter_test.dart';

import 'package:read_space/main.dart';

void main() {
  testWidgets('ReadSpace app launches to splash and onboarding flow', (tester) async {
    await tester.pumpWidget(const ReadSpaceApp());

    expect(find.text('ReadSpace'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Welcome to ReadSpace — your smart library companion.'), findsOneWidget);
  });
}
