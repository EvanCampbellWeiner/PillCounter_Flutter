import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'iapotheca_theme.dart';

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

  // runApp(const TfliteScreen());
  runApp(const HomeScreen());
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
      home: const Home(), // home.dart KYLE (added pill in params)
    );
  }
}