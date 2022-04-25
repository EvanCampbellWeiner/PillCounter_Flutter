import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/iapotheca_theme.dart';
import 'pillinformation.dart';
import 'report.dart';

/**
   Main | 
   Purpose: Loads first homescreen with global settings.
 */
Future<void> main() async {
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

/**
 * Home Class |
 * Purpose: Constructs and contains the State for Home.
 */
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

/**
 * HomeState |
 * Purpose: Contains the information for the Home Class to then be used by the
 * HomeScreen widget in main.dart
 */
class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = iApothecaTheme.light();
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
