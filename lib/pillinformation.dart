import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'camerawidgets.dart';


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
// 1
class PillInformationForm extends StatefulWidget {
  const PillInformationForm({Key? key}) : super(key: key);

  @override
  _PillInformationFormState createState() => _PillInformationFormState();
}

class _PillInformationFormState extends State<PillInformationForm> {
  final _dinController = TextEditingController();
  String _din = '00326925';
  late Future<PillInformation> _futurePillInformation;

  @override void initState() {
    _dinController.addListener(() {
      setState(() {
        _din = _dinController.text;
      });
    });
    super.initState();
    _futurePillInformation = fetchPillInformation(_dinController.text);
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
                controller: _dinController,
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
                    MaterialPageRoute(builder: (context) => PillInformationForm()),
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
                  }
              ),
            ],
          ),
        ),
        bottomNavigationBar: Center( child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFormField(
          controller: _dinController,
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
              MaterialPageRoute(builder: (context) => TakePictureScreen(
              camera: cameras.first
              )),
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
            }
        ),
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
