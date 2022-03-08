//
// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as imageLib;
// import './tensorflow2.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
//
// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// //
// // /// Represents the recognition output from the model
// class Recognition {
//   /// Index of the result
//   int _id;
//
//   /// Label of the result
//   String _label;
//
//   /// Confidence [0.0, 1.0]
//   double _score;
//
//   /// Location of bounding box rect
//   ///
//   /// The rectangle corresponds to the raw input image
//   /// passed for inference
//  late Rect _location;
//
//   Recognition(this._id, this._label, this._score, this._location);
//
//   int get id => _id;
//
//   String get label => _label;
//
//   double get score => _score;
//
//   Rect get location => _location;
//
//   /// Returns bounding box rectangle corresponding to the
//   /// displayed image on screen
//   ///
//   /// This is the actual location where rectangle is rendered on
//   /// the screen
//   Rect get renderLocation {
//     // ratioX = screenWidth / imageInputWidth
//     // ratioY = ratioX if image fits screenWidth with aspectRatio = constant
//
//     double ratioX = CameraViewSingleton.ratio;
//     double ratioY = ratioX;
//
//     double transLeft = max(0.1, location.left * ratioX);
//     double transTop = max(0.1, location.top * ratioY);
//     double transWidth = min(
//         location.width * ratioX, CameraViewSingleton.actualPreviewSize.width);
//     double transHeight = min(
//         location.height * ratioY, CameraViewSingleton.actualPreviewSize.height);
//
//     Rect transformedRect =
//     Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
//     return transformedRect;
//   }
//
//   @override
//   String toString() {
//     return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
//   }
// }
// //
// // /// Runs object detection on the input image
// // Map<String, dynamic> predict(imageLib.Image image) {
// //   var predictStartTime = DateTime.now().millisecondsSinceEpoch;
// //
// //   if (_interpreter == null) {
// //     print("Interpreter not initialized");
// //     return null;
// //   }
// //
// //   var preProcessStart = DateTime.now().millisecondsSinceEpoch;
// //
// //   // Create TensorImage from image
// //   TensorImage inputImage = TensorImage.fromImage(image);
// //
// //   // Pre-process TensorImage
// //   inputImage = getProcessedImage(inputImage);
// //
// //   var preProcessElapsedTime =
// //       DateTime.now().millisecondsSinceEpoch - preProcessStart;
// //
// //   // TensorBuffers for output tensors
// //   TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
// //   TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
// //   TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
// //   TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);
// //
// //   // Inputs object for runForMultipleInputs
// //   // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
// //   List<Object> inputs = [inputImage.buffer];
// //
// //   // Outputs map
// //   Map<int, Object> outputs = {
// //     0: outputLocations.buffer,
// //     1: outputClasses.buffer,
// //     2: outputScores.buffer,
// //     3: numLocations.buffer,
// //   };
// //
// //   var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;
// //
// //   // run inference
// //   _interpreter.runForMultipleInputs(inputs, outputs);
// //
// //   var inferenceTimeElapsed =
// //       DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;
// //
// //   // Maximum number of results to show
// //   int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));
// //
// //   // Using labelOffset = 1 as ??? at index 0
// //   int labelOffset = 1;
// //
// //   // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
// //   List<Rect> locations = BoundingBoxUtils.convert(
// //     tensor: outputLocations,
// //     valueIndex: [1, 0, 3, 2],
// //     boundingBoxAxis: 2,
// //     boundingBoxType: BoundingBoxType.BOUNDARIES,
// //     coordinateType: CoordinateType.RATIO,
// //     height: INPUT_SIZE,
// //     width: INPUT_SIZE,
// //   );
// //
// //   List<Recognition> recognitions = [];
// //
// //   for (int i = 0; i < resultsCount; i++) {
// //     // Prediction score
// //     var score = outputScores.getDoubleValue(i);
// //
// //     // Label string
// //     var labelIndex = outputClasses.getIntValue(i) + labelOffset;
// //     var label = _labels.elementAt(labelIndex);
// //
// //     if (score > THRESHOLD) {
// //       // inverse of rect
// //       // [locations] corresponds to the image size 300 X 300
// //       // inverseTransformRect transforms it our [inputImage]
// //       Rect transformedRect = imageProcessor.inverseTransformRect(
// //           locations[i], image.height, image.width);
// //
// //       recognitions.add(
// //         Recognition(i, label, score, transformedRect),
// //       );
// //     }
// //   }
// //
// //   var predictElapsedTime =
// //       DateTime.now().millisecondsSinceEpoch - predictStartTime;
// //
// //   return {
// //     "recognitions": recognitions,
// //   };
// // }