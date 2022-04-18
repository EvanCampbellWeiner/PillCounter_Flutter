// ignore_for_file: slash_for_doc_comments

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart' as io;
import 'main.dart';
import 'camerawidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pillcounter.dart';

/**
   Pill Information Class (Object)
   Purpose: Holds all of the information for a single pill type / count.
 */
class PillInformation {
  final String din;
  final String description;
  int count;

  void increment() => count++;
  void decrement() => count--;

  PillInformation({
    required this.din,
    required this.description,
    this.count = 0,
  });

  factory PillInformation.fromJson(Map<String, dynamic> json) {
    return PillInformation(
      din: json['drug_identification_number'],
      description: json['brand_name'],
      count: json['count'] ?? 0,
    );
  }

  static Map<String, dynamic> toMap(PillInformation pill) => {
        'drug_identification_number':pill.din,
        'brand_name':pill.description,
        'count': pill.count,
      };

  static String encode(List<PillInformation> Pills) => json.encode(
        Pills
            .map<Map<String, dynamic>>((pill) => PillInformation.toMap(pill))
            .toList(),
      );

  static List<PillInformation> decode(String pills) =>
      (json.decode(pills) as List<dynamic>)
          .map<PillInformation>((item) => PillInformation.fromJson(item))
          .toList();
}

// Providing http.Client allows the application to provide the correct http.Client
// depending on the situation/device you are using.
// Flutter + Server-side projects: provide a http.IOClient
Future<PillInformation> fetchPillInformation(
    String din, http.Client client) async {
  try {
    final response = await client.get(Uri.parse(
        'https://health-products.canada.ca/api/drug/drugproduct/?din=' + din));
    final jsonresponse = jsonDecode(response.body);

    /// Check that the validity of the response
    if ((response.statusCode == 200) && ((jsonresponse != 0))) {
      PillInformation pillinfo = PillInformation.fromJson(jsonresponse[0]);
      return pillinfo;
    } else {
      return PillInformation(din: din, description: 'Could not find din');
    }
  } catch (e) {
    return PillInformation(din: din, description: 'CDD Error');
  }
}

/**
   Pill Information Review Class
   Purpose: Constructs and contains the state for the pill information review page
*/
class PillInformationReview extends StatefulWidget {
  PillInformationReview({
    Key? key,
  }) : super(key: key);

  @override
  _PillInformationReviewState createState() => _PillInformationReviewState();
}

//TODO: Create a From component consisting of TextField components populated with Pill Information and present to user
/**
   Pill Information Review State
   Purpose: Creates a form to allow users to review pill information 
 */
class _PillInformationReviewState extends State<PillInformationReview> {
  final _dinTextInputController = TextEditingController();
  final _descTextInputController = TextEditingController();
  final _cntTextInputController = TextEditingController();

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pillinfo =
        ModalRoute.of(context)!.settings.arguments as PillInformation;
    _dinTextInputController.text = pillinfo.din;
    _descTextInputController.text = pillinfo.description;
    _cntTextInputController.text = pillinfo.count.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pill Information',
          // 2
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _dinTextInputController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: "DIN",
                errorText: null,
                border: OutlineInputBorder(),
              ),
            ),
            // KYLE (another text form field for the description)
            SizedBox(height: 25),
            TextFormField(
              controller: _descTextInputController,
              keyboardType: TextInputType.text,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: "Description",
                errorText: null,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),
            TextField(
              //enabled: false,
              controller: _cntTextInputController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              decoration: InputDecoration(
                labelText: "Count",
                hintText: "0",
                errorText: null,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String? pillReportString = prefs.getString('pillcounts');
                List<PillInformation> pillReport =
                   pillReportString != null ? PillInformation.decode(pillReportString) : List.filled(1,PillInformation(
                       din: _dinTextInputController.text,
                       description: _descTextInputController.text,
                       count: 0) , growable: true);

                pillReport.add(PillInformation(
                    din: _dinTextInputController.text,
                    description: _descTextInputController.text,
                    count: 0));
                final String result = PillInformation.encode(pillReport);
                await prefs.setString('pillcounts', (result));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const PillCounter()),
                );
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      ),
      // TODO: Add bottom navigation bar
    );
  }
}

/**

  Pill Information DIN Component
  Purpose: A component that has a textfield for a DIN and a button to retrieve results.

*/
class DINInputFormState extends State<DINInputForm> {
  // Contains the form state
  final _formKey = GlobalKey<FormState>();

  // Contains the contents of the textFormField
  final dinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        TextFormField(
          validator: (value) {
            if (value == null ||
                value.isEmpty ||
                value.characters.length != 8) {
              return 'Please enter a valid 8 digit DIN';
            }
            return null;
          },
          controller: dinController,
          keyboardType: TextInputType.number,
          maxLength: 8,
          decoration: const InputDecoration(
            labelText: 'Enter DIN for Pill',
            errorText: null,
            border: OutlineInputBorder(),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              try {
                PillInformation pillinfo =
                    PillInformation(din: "", description: "");
                await fetchPillInformation(dinController.text, io.IOClient())
                    .then((PillInformation result) {
                  setState(() {
                    pillinfo = result;
                  });
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PillInformationReview(),
                      settings: RouteSettings(arguments: pillinfo)),
                );
                // }
              } catch (Exception) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PillInformationReview(),
                      settings: RouteSettings(
                          arguments: PillInformation(
                              din: "00000000", description: "Error"))),
                );
              }
            }
          },
          child: const Text('Submit'),
        ),
      ]),
    );
  }
}

/**

    Pill Information DIN Component Stateless
    Purpose: A component that has a textfield for a DIN and will gather api information based on the inputted value.

 */
class DINInputForm extends StatefulWidget {
  const DINInputForm({Key? key}) : super(key: key);

  @override
  DINInputFormState createState() {
    return DINInputFormState();
  }
}
