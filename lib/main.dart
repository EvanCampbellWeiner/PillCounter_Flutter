import 'dart:async';
//import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tflite/tflite.dart';
import 'home.dart';
import 'iapotheca_theme.dart';
import 'report.dart';
import 'tflitetest.dart';

import 'tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart';

List<CameraDescription> cameras = [];

/**
   Main | 
   Purpose: Loads first homescreen with global settings.
 */
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  runApp(const TfliteScreen());
}

/**
 HomeScreen | 
 Purpose: HomeScreen contains theme, title and home screen information.
 Returns an application that instantiates Home() from home.dart
*/
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = iApothecaTheme.light();
    return MaterialApp(
      theme: theme,
      title: 'CountrAI',
      home: const Home(), // home.dart
    );
  }
}

/** TODO Remove this if it is deprecated / not the widget used anymore. Otherwise remove
class SessionReportScreen extends StatelessWidget {
  SessionReportScreen({Key? key}) : super(key: key);
  static const String _title = 'Session Report';

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = iApothecaTheme.light();
    return MaterialApp(
      theme: theme,
      title: '_title',
      home: Scaffold(
          appBar: AppBar(title: const Text(_title), centerTitle: true),
          body: SessionReport(),
          bottomNavigationBar: Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  },
                  child: Row(
                    children: [
                     const Icon(Icons.add),
                     const Text(' New Count'),
                    ],
                  )),
              ElevatedButton(
                onPressed: () {
                  Share.share('I will put the export file here!',
                      subject: 'Count of Pills');
                },
                child: Row(
                  children: [
                    const Icon(Icons.ios_share),
                    const Text(' Export'),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          )),
    );
  }
}
*/