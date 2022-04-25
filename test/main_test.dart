import 'package:flutter_test/flutter_test.dart';
import 'package:pillcounter_flutter/main.dart';
import 'package:pillcounter_flutter/pillinformation.dart';

void main() {
  testWidgets('finds a Title widget', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeScreen());
    final titleFind = find.text('Pill Counter');
    final dinFind = find.text('Enter DIN for Pill');
    expect(titleFind, findsOneWidget);
    expect(dinFind, findsOneWidget);
  });
}