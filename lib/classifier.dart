
import 'dart:math';
import 'dart:ui';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:pillcounter_flutter/recognition.dart';
import './tensorflow2.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
/// Classifier
class Classifier {
  /// Instance of Interpreter
  Interpreter? _interpreter;

  /// Labels file loaded as list
  List<String>? _labels;

  static const String MODEL_FILE_NAME = "model.tflite";
  static const String LABEL_FILE_NAME = "model.txt";

  /// Input size of image (height = width = 300)
  static const int INPUT_SIZE = 640;

  /// Result score threshold
  static const double THRESHOLD = 0;

  /// [ImageProcessor] used to pre-process the image
  late ImageProcessor imageProcessor;

  /// Padding the image to transform into square
  late int padSize;

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;

  /// Types of output tensors
 late  List<TfLiteType> _outputTypes;

  /// Number of results to show
  static const int NUM_RESULTS = 10;

  Classifier() {
    loadModel();
    loadLabels();
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter!.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
      dev.log(_outputShapes.toString()+" output shapes");
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  void loadLabels({

    List<String>? labels}) async {
    try {
      _labels =
          labels ?? await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
      imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  /// Runs object detection on the input image
  Future<List<dynamic>?> predict(imageLib.Image image) async {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;
    var outputTensors = _interpreter!.getOutputTensors();
    _outputShapes = [];
    _outputTypes = [];
    outputTensors.forEach((tensor) {
      dev.log(tensor.toString());
      _outputShapes.add(tensor.shape);
      _outputTypes.add(tensor.type);
    });
    // TensorBuffers for output tensors
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[1]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[3]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[2]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    dev.log("here");

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    // _interpreter!.runForMultipleInputs(inputs, outputs);
  dev.log("here");
    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(NUM_RESULTS, 3);

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [0,1,2,3],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.PIXEL,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      var score = outputScores.getDoubleValue(i);

      // Label string
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels!.elementAt(labelIndex);
      // dev.log(recognitions.toString()+"HERE TODAY");
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor.inverseTransformRect(
            locations[i], image.height, image.width);
        dev.log(recognitions.toString()+"HERE TODAY");
        recognitions.add(
          Recognition(i, "pill", 0.5, transformedRect),
        );
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return recognitions;
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String>? get labels => _labels;
}