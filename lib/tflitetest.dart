import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillcounter_flutter/tensorflow2.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'home.dart';
import 'iapotheca_theme.dart';
import 'report.dart';
// import 'camerawidgets.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'classifier.dart';

const String mobile = "MobileNet";
const String ssd = "SSD MobileNet";
const String yolo = "YOLO";
const String deeplab = "DeepLab";
const String posenet = "PoseNet";
dynamic _pickImageError;

class TfliteTest extends StatefulWidget {
  const TfliteTest({Key? key}) : super(key: key);

  @override
  _TfliteTestState createState() => _TfliteTestState();
}

class _TfliteTestState extends State<TfliteTest> {
  File? _image;
  List _recognitions = [];
  String _model = yolo;
  double _imageHeight = 384;
  double _imageWidth = 384;
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  Future predictImagePicker() async {
    print("predictImagePicker");

    var _picker = ImagePicker();
    var image = null;
    try {
      image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 5000,
          maxWidth: 5000,
          imageQuality: 75);
      if (image == null) return;
      setState(() {
        _busy = true;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
        dev.log("caught error");
        print(e);
      });
    }
    dev.log("predicting image...");
    predictImage(File(image.path));
    dev.log("fixed");
  }

  Future predictImage(File image) async {
    if (image == null) return;
    switch (_model) {
      case yolo:
      print("yolo");
      await yolov2Tiny(image);
      break;
      case ssd:
        await ssdMobileNet(image);
        break;
      default:
        print("default");
        await recognizeImage(image);
    // await recognizeImageBinary(image);
    }

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _image = image;
      _busy = false;
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String? res;
      switch (_model) {
        case yolo:
          res = await Tflite.loadModel(
            model: "assets/yolov5s.tflite",
            labels: "assets/yolov5s.txt",
            // useGpuDelegate: true,
          );
          break;
        case ssd:
          res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt",
            // useGpuDelegate: true,
          );
          break;
        case deeplab:
          res = await Tflite.loadModel(
            model: "assets/deeplabv3_257_mv_gpu.tflite",
            labels: "assets/deeplabv3_257_mv_gpu.txt",
            // useGpuDelegate: true,
          );
          break;
        case posenet:
          res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
            // useGpuDelegate: true,
          );
          break;
        default:
          res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt",
            // useGpuDelegate: true,
          );
      }
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Uint8List imageToByteListFloat32(img.Image image, int inputSize, double mean,
      double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future recognizeImage(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future recognizeImageBinary(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image? oriImage = img.decodeJpg(imageBytes.asUint8List());
    img.Image resizedImage = img.copyResize(oriImage!, height: 224, width: 224);
    var recognitions = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizedImage, 224, 127.5, 127.5),
      numResults: 6,
      threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future yolov2Tiny(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var imageb = (await image.readAsBytes());
    // var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image? oriImage = img.decodeJpg(imageb);
    // img.Image? image2 = img.decodeJpg(imageb);
    img.Image? resizedImage = img.copyResize(oriImage!, height:384, width:384);
    // dev.log("resized image:" + resizedImage.width.toString());
    // resizedImage.getBytes().shape.reshape([1,640,640,3]);
    // dev.log("resized image:"+resizedImage.getBytes().shape.toString());

    Classifier classifier =  await Classifier();

    await classifier.loadModel();
    // if (classifier.interpreter != null && classifier.labels != null) {
      dev.log("Running predict...");

      var results = await classifier.predict(
          resizedImage);
      // resizedImage = img.drawRect(resizedImage,results!.first.location.left,results!.first.location.top, results!.first.location.right, results!.first.location.bottom, 0  );
      // results = classifier.predict(resizedImage) as List?;
      _recognitions = results!;
      if (classifier.interpreter != null) {
        classifier.interpreter!.close();
      }
  }


  Future ssdMobileNet(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      numResultsPerClass: 1,
    );
    // var imageBytes = (await rootBundle.load(image.path)).buffer;
    // img.Image oriImage = img.decodeJpg(imageBytes.asUint8List());
    // img.Image resizedImage = img.copyResize(oriImage, 300, 300);
    // var recognitions = await Tflite.detectObjectOnBinary(
    //   binary: imageToByteListUint8(resizedImage, 300),
    //   numResultsPerClass: 1,
    // );
    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future segmentMobileNet(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runSegmentationOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}");
  }

  Future poseNet(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );

    print(recognitions);

    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  onSelect(model) async {
    setState(() {
      _busy = true;
      _model = model;
      _recognitions = [];
    });
    await loadModel();

    if (_image != null)
      predictImage(_image!);
    else
      setState(() {
        _busy = false;
      });
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = _imageWidth/screen.width * screen.width;
    double factorY = _imageWidth/screen.width * screen.width;
    var length = _recognitions.length;
    Color blue = Color.fromRGBO(37, 213, 253, 1.0);
    return _recognitions.map((re) {
      Rect rec = re.renderLocation;
      return Positioned(
        left: (rec.left),
        top: (rec.top),
        height: rec.height,
        width: rec.width,

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: blue,
              width: 2,
            ),
          ),
          child: Text(
            "${(re.id).toStringAsFixed(0)}",
            style: TextStyle(
              background: Paint()
                ..color = blue,
              color: Colors.red,
              fontSize: re.id == length-1 ? 12.0 : 10,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists..addAll(list);
    });

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: 384,
      height: 384,
      child: _image == null ? Text('No image selected.') : Image.file(
          _image!),
    ));

    if (_model == mobile) {
      stackChildren.add(Center(
        child: Column(
          children: _recognitions != null
              ? _recognitions.map((res) {
            return Text(
              "${res["index"]} - ${res["label"]}: ${res["confidence"]
                  .toStringAsFixed(3)}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()
                  ..color = Colors.white,
              ),
            );
          }).toList()
              : [],
        ),
      ));
    } else if (_model == ssd || _model == yolo) {
      stackChildren.addAll(renderBoxes(size));
    } else if (_model == posenet) {
      stackChildren.addAll(renderKeypoints(size));
    }

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('tflite example app'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: onSelect,
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> menuEntries = [
                const PopupMenuItem<String>(
                  child: Text(mobile),
                  value: mobile,
                ),
                const PopupMenuItem<String>(
                  child: Text(ssd),
                  value: ssd,
                ),
                const PopupMenuItem<String>(
                  child: Text(yolo),
                  value: yolo,
                ),
                const PopupMenuItem<String>(
                  child: Text(deeplab),
                  value: deeplab,
                ),
                const PopupMenuItem<String>(
                  child: Text(posenet),
                  value: posenet,
                )
              ];
              return menuEntries;
            },
          )
        ],
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: predictImagePicker,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}