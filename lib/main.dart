/// CountrAI
///
/// Created by: Nicholas Barnes, Evan Campbell-Weiner, Myles Lee and Kyle Burke
/// as a capstone project for Trent University and a client.
///
/// Description: Created as a capstone project for Trent University and
/// a client. This mobile application was created with the goal of providing
/// pharmacies with an affordable, portable and intuitive tool to count pills.
///
/// Using a COCO SSD MobileNet v1 model and transfer learning, our model as been
/// trained to detect pills in an image. The number of recognitions is then
/// tallied up and presented to the user as an overall count of the pills.
///
/// The model has been implemented into our app with TFLite, using the
/// tflite_flutter and tflite_flutter_helper packages.
///
/// To achieve better results, consider creating a larger dataset and retraining
/// the model.
///

/// main.dart
///
/// The main driver of the application. Calls the runApp() function on
/// HomeScreen(), which returns the Material App and instantiates Home()
///
import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'pillinformation.dart';
import 'report.dart';

/// main()
///
/// Purpose: Loads first homescreen with global settings.

Future<void> main() async {
  runApp(const HomeScreen());
}

/// HomeScreen
///
/// Purpose: HomeScreen contains theme, title and home screen information.
///
/// Returns an application that instantiates Home() from home.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light();
    return MaterialApp(
      theme: theme,
      title: 'CountrAI',
      home: const Home(),
    );
  }
}

/// Home Class
///
/// Purpose: Constructs and contains the State for Home.
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

/// HomeState
///
/// Purpose: Contains the information for the Home Class to then be used by the
/// HomeScreen widget in main.dart
class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pill Counter'),
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
          children: const [
            DINInputForm(),
          ],
        ),
      ),
    );
  }
}
