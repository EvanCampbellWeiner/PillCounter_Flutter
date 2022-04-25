import 'package:flutter_test/flutter_test.dart';
import 'package:pillcounter_flutter/main.dart';

void main() {
  testWidgets('can load screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeScreen());
    final titleFind = find.text('Pill Counter');
    expect(titleFind, findsOneWidget);

  });
}