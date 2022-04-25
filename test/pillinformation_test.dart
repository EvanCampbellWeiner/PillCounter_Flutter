import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:pillcounter_flutter/pillinformation.dart';
// Generate a MockClient using Mockito
// Create new instances of this class in each test.
@GenerateMocks([http.Client])
void main() {
  testWidgets('loads with pill data', (WidgetTester tester) async {
    final PillInformation pillinfo = PillInformation(din:'00000019', description:"Random Pill");

    await tester.pumpWidget(MaterialApp(
      home: Navigator(
        onGenerateRoute: (_) {
          return MaterialPageRoute<Widget>(
            builder: (_) => PillInformationReview(),
            settings: RouteSettings(arguments: ScreenArguments(pillinfo, null)),
          );
        },
      ),
    ));

    // Flutter won't automatically rebuild your widget in the test environment
    // Do tester.pump(Duration duration) to trigger a rebuild.
    final dinFind = find.text('00000019');
    final descriptionFind = find.text('Random Pill');
    expect(dinFind, findsOneWidget);
    expect(descriptionFind, findsOneWidget);
  });

}