import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pillcounter_flutter/main.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:pillcounter_flutter/report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fetch_pill_info_test.mocks.dart';

void main() {
  testWidgets('loads the page', (WidgetTester tester) async {
      final PillInformation pillinfo = PillInformation(din:'00000019', description:"Random Pill");
      final PillInformation pillinfo2 = PillInformation(din:'00000020', description:"Random Pill2");
      List<PillInformation> list = List.empty(growable:true);
      list.add(pillinfo);
      list.add(pillinfo2);
      Map<String, Object> values = <String, Object>{'pillcounts':list };
      SharedPreferences.setMockInitialValues(values);

      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) {
            return MaterialPageRoute<Widget>(
              builder: (_) => SessionReport(),
            );
          },
        ),
      ));
      final titleFind = find.text('Session Report');
      expect(titleFind, findsOneWidget);
  });
}