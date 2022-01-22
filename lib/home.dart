import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pillinformation.dart';
import 'report.dart';
import 'iapotheca_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io;

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
  //
  // Allows us to access the contents of a Text Field.
  final _dinTextInputController = TextEditingController();

  // Value of the text field
//  String _din = '0';
  late Future<PillInformation> _futurePillInformation;

  @override
  void initState() {
    _dinTextInputController.addListener(() {
      setState(() {
        //      _din = _dinTextInputController.text;
      });
    });
    super.initState();
    _futurePillInformation =
        fetchPillInformation(_dinTextInputController.text, io.IOClient());
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
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
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
    );
  }
}
