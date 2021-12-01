import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pillinformation.dart';

// 1
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
            'CountrAI',
            // 2
            style: Theme.of(context).textTheme.headline6,
          ),
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
        )

        // TODO: Add bottom navigation bar
        );
  }
}
