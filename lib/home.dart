import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 1
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // TODO: Add state variables and functions

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
                keyboardType: TextInputType.number,
                initialValue: '000000',
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter DIN for Pill',
                  errorText: null,
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: Text('Search'),
              ),
            ],
          ),
        )

        // TODO: Add bottom navigation bar
        );
  }
}
