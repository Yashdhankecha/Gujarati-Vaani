import 'package:flutter_test/flutter_test.dart';

import 'package:gujarati_vaani_app/main.dart';

void main() {
  testWidgets('shows the TTS screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GujaratiVaaniApp());

    expect(find.text('Gujarati Vaani'), findsOneWidget);
    expect(find.text('Gujarati Text-to-Speech'), findsOneWidget);
    expect(find.text('Generate Speech'), findsOneWidget);
  });
}
