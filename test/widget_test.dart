import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mama_moodeng/mama_moodeng_app.dart';

void main() {
  testWidgets('Mama Moodeng home shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MamaMoodengApp()));
    await tester.pumpAndSettle();

    expect(find.text('Mama Moodeng'), findsOneWidget);
    expect(find.text('Medical Dictionary'), findsNothing);
  });
}
