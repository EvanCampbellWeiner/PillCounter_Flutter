import 'package:flutter_test/flutter_test.dart';
import 'package:pillcounter_flutter/main.dart';

void main() {
  testWidgets('finds a Title widget', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeScreen());

    // Flutter won't automatically rebuild your widget in the test environment
    // Do tester.pump(Duration duratoin) to trigger a rebuild.

    final titleFind = find.text('Pill Counter');

    expect(titleFind, findsOneWidget);



  });
}