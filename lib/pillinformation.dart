/// pillinformation.dart
///
/// Contains build method and supporting functions for the DIN Input and
/// Pill Information pages.
/// The Pill Information page is used in two seperate contexts, the first of
/// which is:
///     1. The DIN Input page consists of a single 8-digit input which is then
///        taken and sent to the Canadian Drug Database.
///     2. The user is then moved to the Pill Information screen with
///        pre-populated form elements.
///     3. After accepting the contents of the PillInformation page, the user is
///        then moved to the Pill Counting screen.
///
/// The alternative flow for the app is:
///     1. The user was previously on the Session Report page (report.dart) and
///        tapped on an element from the list.
///     2. The app then sends the PillInformation object and it's index in the
///        Session Report, a List<PillInformation>, to the Pill Information
///        screen.
///     3. The user is then moved to the Pill Information screen, which has been
///        pre-populated using the passed PillInformation object
///

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'pillcounter.dart';
import 'dart:developer' as dev;
import 'report.dart';

/// PillInformation Class
///
/// Purpose: Holds all of the information for a single pill type / count.
///
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

  /// PillInformation.fromJson
  ///
  /// Purpose: Accepts a json string representing a PillInformation object and
  /// calls the PillInformation constructor to create a PillInformation object,
  /// then returns it.
  ///
  /// Returns: A PillInformation object
  ///
  factory PillInformation.fromJson(Map<String, dynamic> json) {
    return PillInformation(
      din: json['drug_identification_number'],
      description: json['brand_name'],
      count: json['count'] ?? 0,
    );
  }

  /// toMap
  ///
  /// Purpose: Maps a PillInformation object to a JSON string.
  ///
  /// Returns: a json-formatted string representing the passed PillInformation
  /// object.
  ///
  static Map<String, dynamic> toMap(PillInformation pill) => {
        'drug_identification_number': pill.din,
        'brand_name': pill.description,
        'count': pill.count,
      };

  /// encode
  ///
  /// Purpose: Accepts a List of PillInformation objects and converts them to a
  /// json string.
  ///
  /// Returns: A json string.
  static String encode(List<PillInformation> Pills) => json.encode(
        Pills.map<Map<String, dynamic>>((pill) => PillInformation.toMap(pill))
            .toList(),
      );

  /// decode
  ///
  /// Purpose: Accepts a json-formatted String and converts it to a List of
  /// PillInformation objects.
  ///
  /// Returns: A List of PillInformation objects
  static List<PillInformation> decode(String pills) =>
      (json.decode(pills) as List<dynamic>)
          .map<PillInformation>((item) => PillInformation.fromJson(item))
          .toList();
}

/// fetchPillInformation
///
/// Purpose: Provided a pill DIN and a http.Client object, send a request to the
/// Canadian Drug Database API. Given a valid response, convert the respnnse to
/// a PillInformation object and return it.
///
/// Returns: A Future<PillInformation> object.
///
/// Note:
/// Providing http.Client allows the application to provide the correct
/// http.Client depending on the situation/device you are using.
/// Flutter + Server-side projects: provide a http.IOClient
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

/// Pill Information Review Class
///
/// Purpose: Constructs and contains the state for the pill information
/// review page
class PillInformationReview extends StatefulWidget {
  PillInformationReview({
    Key? key,
  }) : super(key: key);

  @override
  _PillInformationReviewState createState() => _PillInformationReviewState();
}

/// Pill Information Review State
///
/// Purpose: Creates a form to allow users to review pill information
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
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    _dinTextInputController.text = (_dinTextInputController.text == '')
        ? args.pInfo.din
        : _dinTextInputController.text;
    _descTextInputController.text = (_descTextInputController.text == '')
        ? args.pInfo.description
        : _descTextInputController.text;
    _cntTextInputController.text = (_cntTextInputController.text == '')
        ? args.pInfo.count.toString()
        : _cntTextInputController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pill Information',
          // 2
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Go To Report',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SessionReport()));
              })
        ],
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
            const Divider(
              height:25,
              color:Colors.white,
            ),
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
            const Divider(
              height:25,
              color:Colors.white,
            ),
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
            ElevatedButton(
              onPressed: () async {
                if (args.ind == null) {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString(
                      'currentCount',
                      jsonEncode(PillInformation.toMap(PillInformation(
                          din: _dinTextInputController.text,
                          description: _descTextInputController.text,
                          count: 0))));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PillCounter()),
                  );
                } else {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final String? pillReportString =
                      prefs.getString('pillcounts');
                  final List<dynamic> pillReport =
                      PillInformation.decode(pillReportString ?? "");
                  int i = args.ind ?? -1; // This will never be null
                  PillInformation updated = PillInformation(
                      din: _dinTextInputController.text,
                      description: _descTextInputController.text,
                      count: int.parse(_cntTextInputController.text));
                  pillReport[i] = updated;
                  final String result = PillInformation.encode(
                      pillReport as List<PillInformation>);
                  prefs.setString('pillcounts', (result));
                  Navigator.pop(context);
                }
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill Information DIN Component
///
/// Purpose: A component that has a textfield for a DIN and a button to retrieve
/// results.
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
              //Validate returns true if the form is valid, or false otherwise.
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
                        settings: RouteSettings(
                            arguments: ScreenArguments(pillinfo, null))),
                  );
                  // }
                } catch (Exception) {
                  PillInformation err =
                      PillInformation(din: "00000000", description: "Error");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PillInformationReview(),
                        settings: RouteSettings(
                            arguments: ScreenArguments(err, null))),
                  );
                }
              }
            },
            child: const Text('Submit'))
      ]),
    );
  }
}

/// Pill Information DIN Component Stateless
///
/// Purpose: A component that has a textfield for a DIN and will gather api
/// information based on the user's input.
class DINInputForm extends StatefulWidget {
  const DINInputForm({Key? key}) : super(key: key);

  @override
  DINInputFormState createState() {
    return DINInputFormState();
  }
}

/// ScreenArguments Class
///
/// Purpose: Used to pass arguments from one screen to another.
class ScreenArguments {
  final PillInformation pInfo;
  final int? ind;

  ScreenArguments(this.pInfo, this.ind);
}
