
import 'dart:math';
import 'dart:typed_data';
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
  static const int INPUT_SIZE = 384;

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
  static const int NUM_RESULTS = 150;

  Classifier() {
    loadModel();
    loadLabels();
  }

  /// Loads interpreter from asset
  Future<void> loadModel({Interpreter? interpreter})  async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 1,
          );
      dev.log("Is allocated: "+_interpreter!.isAllocated.toString());

      dev.log("Input tensors"+_interpreter!.getInputTensors().toString());
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
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }


  /// Runs object detection on the input image
  Future<List<dynamic>?> predict(imageLib.Image image) async {
    // For Logging
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;
    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
   TensorImage  inputImage = TensorImage(TfLiteType.uint8);
   inputImage.loadImage(image);
    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    // Logging
    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // TensorBuffers for output tensors
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[1]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[3]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[2]);


    // dev.log(inputImage.getDataType().toString());
    // // Inputs object for runForMultipleInputs
    // // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    // dev.log(inputImage.buffer.toString());

    // img.Image? oriImage = img.decodeJpg(imageBytes.asUint8List());
    // img.Image? image2 = img.decodeJpg(imageb);
    // img.Image? oriImage = img.decodeJpg(imageBytes.asUint8List());
    // var imgBytes = image.getBytes();
    //
    // List<Object> inputs = [imgBytes.first];
    var image2 = image.getBytes();
    // inputImage.buffer.asUint8List().reshape([1,640,640,3]);
    // dev.log(inputImage.tensorBuffer.getBuffer().asUint8List().reshape([1,640,640,3]).toString());
    // dev.log("Input Image:"+inputImage.tensorBuffer.getBuffer().asInt8List().reshape([1,640,640,3]).toString());
    var inputs = inputImage.buffer.asUint8List();


    dev.log("Input Tensors are: " + _interpreter!.getInputTensors().toString());
    dev.log("Input Shape is:" + inputs.shape.toString());
    dev.log("Input Type is:" + inputs.runtimeType.toString());

    // Outputs map
    Map<int, Object> outputs = {
      0: outputScores.buffer,
      1: outputLocations.buffer,
      2: numLocations.buffer,
      3: outputClasses.buffer,
    };
    dev.log("HERE");

    // dev.log(outputs[0].toString());

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // dev.log();
    // dev.log(tensorImage.buffer.asUint8List());
    dev.log("Inputs:"+inputs.toString());
    dev.log("Interpreter input tensors:"+_interpreter!.getInputTensors().toString());
    dev.log("Output Hash Map: "+ outputs.runtimeType.toString());
    dev.log("Output Shape: "+outputs[0]!.toString());


    // run inference
    _interpreter!.runForMultipleInputs([inputs], outputs);


    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;
    // _interpreter.resize_tensor_input(0, [1, input_shape[0], input_shape[1], 3], strict=True)
    // Maximum number of results to show
    int resultsCount = min(NUM_RESULTS, 150);

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // dev.log("HERE");

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [0,2,1,3],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.CENTER,
      coordinateType: CoordinateType.PIXEL,
      height: image.height,
      width: image.width,
    );

    List<Recognition> recognitions = [];
    var count = 0;
    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      var score = outputScores.getDoubleValue(i);
      dev.log(numLocations.buffer.asInt8List.toString());

      if(score > 0.25) {
        count++;
        //Label string
        // var labelIndex = outputClasses.getIntValue(i) + labelOffset;
        var label = _labels!.elementAt(0);
        dev.log(recognitions.toString()+"HERE TODAY");
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor.inverseTransformRect(
        locations[i], image.height, image.width);
        // dev.log(recognitions.toString()+"HERE TODAY");
        recognitions.add(
        Recognition(i, "pill", score, transformedRect),
        );
      }
    }

    dev.log("number of items: "+count.toString());
    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return recognitions;
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String>? get labels => _labels;
}