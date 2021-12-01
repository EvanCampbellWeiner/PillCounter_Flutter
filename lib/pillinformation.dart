import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PillInformation {
  final String din;
  final String description;
  int count = 0;

  PillInformation({
    required this.din,
    required this.description,
  });

  factory PillInformation.fromJson(Map<String, dynamic> json) {
    return PillInformation(
      din: json['drug_identification_number'],
      description: json['brand_name'],
    );
  }
}

Future<PillInformation> fetchPillInformation(String din) async {
  final response = await http.get(Uri.parse(
      'https://health-products.canada.ca/api/drug/drugproduct/?din=' + din));
  final jsonresponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return PillInformation.fromJson(jsonresponse[0]);
  } else {
    throw Exception('Failed to load pill information');
  }
}
