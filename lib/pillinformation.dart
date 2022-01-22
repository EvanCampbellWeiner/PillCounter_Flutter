import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart' as io;
import 'main.dart';
import 'camerawidgets.dart';

/**
   Pill Information Class (Object)
   Purpose: Holds all of the information for a single pill type / count.
 */
class PillInformation {
  final String din;
  final String description;
  int count = 0;

  void increment() => count++;
  void decrement() => count--;

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

// Providing http.Client allows the application to provide the correct http.Client
// depending on the situation/device you are using.
// Flutter + Server-side projects: provide a http.IOClient
Future<PillInformation> fetchPillInformation(
    String din, http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://health-products.canada.ca/api/drug/drugproduct/?din=' + din));
  final jsonresponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    PillInformation pillinfo = PillInformation.fromJson(jsonresponse[0]);
    if (pillinfo.din == din) {
      return PillInformation.fromJson(jsonresponse[0]);
    } else {
      throw Exception(
          'DINS dont match'); // TODO: Handle incorrect response from API
    }
  } else {
    throw Exception('Failed to load pill information');
  }
}

/**
   Pill Information Review Class
   Purpose: Constructs and contains the state for the pill information review page
*/
class PillInformationReview extends StatefulWidget {
  const PillInformationReview({Key? key}) : super(key: key);

  @override
  _PillInformationReviewState createState() => _PillInformationReviewState();
}

//TODO: Create a From component consisting of TextFIeld components populated with Pill Information and present to user
/**
   Pill Information Review State
   Purpose: Creates a form to allow users to review pill information 
 */
class _PillInformationReviewState extends State<PillInformationReview> {
  final _dinTextInputController = TextEditingController();

  late Future<PillInformation> _futurePillInformation;

  @override
  void initState() {
    _dinTextInputController.addListener(() {
      setState(() {});
    });

    super.initState();
    // We pass io.IOClient because it is a flutter/server-side project.
    _futurePillInformation =
        fetchPillInformation(_dinTextInputController.text, io.IOClient());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm Pill Information',
          // 2
        ),
        centerTitle: true,
      ),
      // TODO: Show selected tab
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _dinTextInputController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'Enter DIN for Pill',
                errorText: null,
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PillInformationReview()),
                );
              },
              child: Text('Search'),
            ),
            FutureBuilder<PillInformation>(
                future: _futurePillInformation,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!.description);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                }),
          ],
        ),
      ),
      bottomNavigationBar: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _dinTextInputController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'Enter DIN for Pill',
                errorText: null,
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TakePictureScreen(camera: cameras.first)),
                );
              },
              child: Text('Search'),
            ),
            FutureBuilder<PillInformation>(
                future: _futurePillInformation,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!.description);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                }),
          ],
        ),
      ),
      // TODO: Add bottom navigation bar
    );
  }
}

Future<CameraDescription> loadCamera() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  return firstCamera;
}
