/// recognition.dart
///
/// Contains Recognition and CameraViewSingleton classes
///

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

/// CameraViewSingleton class
///
/// A Singleton that records data pertaining to the screen size,
/// input image size, and preview size.
class CameraViewSingleton {
  static double ratio = 1;
  static Size screenSize = Size(384, 384);
  static Size inputImageSize = Size(384, 384);
  static Size get actualPreviewSize =>
      Size(screenSize.width, screenSize.width * ratio);
}

/// Recognition class
///
/// Represents the recognition output from the Interpreter (model)
///
/// Contains:
///
///     - _id: The index of the result in the List of Recognitions.
///
///     - _label: The classification of the result, we only have a single
///       classifier so this will always be pill.
///
///     - _score: The confidence score of the detection. A double with values
///       [0.0, 1.0] that represents the confidece score of the detection.
///
///     - _location: A Rect object with the location of the bounding box rect.
class Recognition {
  /// Index of the result
  int _id;

  /// Label of the result
  String _label;

  /// Confidence [0.0, 1.0]
  double _score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  Rect _location;

  Recognition(this._id, this._label, this._score, this._location);

  int get id => _id;

  String get label => _label;

  double get score => _score;

  Rect get location => _location;

  /// renderLocation
  ///
  /// Purpose:
  /// Returns bounding box rectangle corresponding to the
  /// displayed image on screen
  ///
  /// This is the actual location where rectangle is rendered on
  /// the screen
  Rect get renderLocation {
    double transLeft = max(0.1, location.left);
    double transTop = max(0.1, location.top);
    double transWidth = location.width;
    double transHeight = location.height;

    Rect transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}
