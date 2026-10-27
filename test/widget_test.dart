import 'package:flutter_test/flutter_test.dart';
import 'package:islami_uygulama/main.dart';

void main() {
  testWidgets('Islami Uygulama smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IslamiUygulamaApp());
    expect(find.text('Ana Sayfa'), findsWidgets);
  });
}
