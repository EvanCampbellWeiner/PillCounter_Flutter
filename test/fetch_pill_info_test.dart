import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../lib/pillinformation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fetch_pill_info_test.mocks.dart';

// Generate a MockClient using Mockito
// Create new instances of this class in each test.
@GenerateMocks([http.Client])
void main() {
  group('fetchPillInformation: ', () {
    test(
        'returns a pill information object if the http call completes successfully',
        () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the provided
      // http.Client
      when(client.get(Uri.parse(
              'https://health-products.canada.ca/api/drug/drugproduct/?din=00000019')))
          .thenAnswer((_) async => http.Response(
              '[{   "drug_code": 2049,  "class_name": "Human", "drug_identification_number": "00000019","brand_name": "SINEQUAN", "descriptor": "",  "number_of_ais": "1", "ai_group_no": "0107703005", "company_name": "AA PHARMA INC", "last_update_date": "2019-03-05"}]',
              200));
      expect(await fetchPillInformation('00000019', client),
          isA<PillInformation>());
    });

// TODO: Update Exception type in test and in fetchPillInformation()
// Consider a custom exception type that checks the din of the PillInformation
// object and the din passed to fetchPillInformation()
    // test('Throws an exception on incorrect din being recieved.', () async {
    //   final client = MockClient();

    //   // Use Mockito to return a successful response when it calls the provided
    //   // http.Client
    //   when(client.get(Uri.parse(
    //           'https://health-products.canada.ca/api/drug/drugproduct/?din=00000019')))
    //       .thenAnswer((_) async => http.Response(
    //           '[{   "drug_code": 2049,  "class_name": "Human", "drug_identification_number": "00326925","brand_name": "SINEQUAN", "descriptor": "",  "number_of_ais": "1", "ai_group_no": "0107703005", "company_name": "AA PHARMA INC", "last_update_date": "2019-03-05"}]',
    //           200));
    //   expect(
    //       fetchPillInformation('00000019', client),
    //       throwsA(predicate(
    //           (e) => e is Exception && e.message == 'DINS dont match')));
    // });
  });
}
