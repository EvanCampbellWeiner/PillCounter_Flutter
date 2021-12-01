import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'home.dart';
import 'iapotheca_theme.dart';
import 'report.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  // 2
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = iApothecaTheme.light();
    return MaterialApp(
      theme: theme,
      title: 'CountrAI',
      home: const Home(),
    );
  }
}

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
        appBar: AppBar(
            title: const Text(_title),
            centerTitle: true),
        body: SessionReport(),
        bottomNavigationBar: Row(
          children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: Row(
                children: [
                  Icon(Icons.add),
                  Text(' New Count'),
                ],
            )

          ),
            ElevatedButton(
              onPressed: () {
                Share.share('I will put the export file here!', subject: 'Count of Pills');
              },
              child: Row(
                  children: [
                    Icon(Icons.ios_share),
                    Text(' Export'),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround ,

        )

      ),

    );
  }
}