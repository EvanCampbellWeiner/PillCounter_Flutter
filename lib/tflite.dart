import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillcounter_flutter/pillcounter.dart';
import 'iapotheca_theme.dart';

/**
 * TFlite Screen
 *
 *
 */
class TfliteScreen extends StatelessWidget {
  // 2
  const TfliteScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = iApothecaTheme.light();
    return MaterialApp(
      theme: theme,
      title: 'CountrAI',
      home: const PillCounter(),
    );
  }
}
