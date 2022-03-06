import 'package:flutter/material.dart';
import 'pillinformation.dart';
import 'iapotheca_theme.dart';

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DINInputForm(),
          ],
        ),
      ),
    );
  }
}
