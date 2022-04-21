import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'classifier.dart';
import 'camerawidgets.dart';
import 'report.dart';

const String model = "model";

dynamic _pickImageError;
late CameraController _cameraController;
late Future<void> _initializeControllerFuture;

class PillCounter extends StatefulWidget {
  const PillCounter({Key? key}) : super(key: key);

  @override
  _PillCounterState createState() => _PillCounterState();
}

class _PillCounterState extends State<PillCounter> {
  File? _image;
  List _recognitions = [];
  String _model = model;
  double _imageHeight = 384;
  double _imageWidth = 384;
  bool _busy = false;
  int _count = 0;

  @override
  void initState() {
    super.initState();

    _busy = true;
  }

  Future<CameraDescription> loadCamera() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    return firstCamera;
  }

  Future predictImage(File image) async {
    if (image == null) return;
    // Add Other Models to Switch
    switch (_model) {
      case model:
        await runModel(image);
        break;
      default:
        throw Exception("Model Not Selected.");
    }

    // Creates File Image
    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    // Sets state of counter page
    setState(() {
      _image = image;
      _busy = false;
    });
  }

  Future runModel(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var imageb = (await image.readAsBytes());
    // var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image? oriImage = img.decodeJpg(imageb);
    // img.Image? image2 = img.decodeJpg(imageb);
    img.Image? resizedImage =
        img.copyResize(oriImage!, height: 384, width: 384);
    // dev.log("resized image:" + resizedImage.width.toString());
    // resizedImage.getBytes().shape.reshape([1,640,640,3]);
    // dev.log("resized image:"+resizedImage.getBytes().shape.toString());

    Classifier classifier = await Classifier();

    await classifier.loadModel();
    // if (classifier.interpreter != null && classifier.labels != null) {
    dev.log("Running predict...");

    var results = await classifier.predict(resizedImage);
    // resizedImage = img.drawRect(resizedImage,results!.first.location.left,results!.first.location.top, results!.first.location.right, results!.first.location.bottom, 0  );
    // results = classifier.predict(resizedImage) as List?;
    _recognitions = results!;
    if (classifier.interpreter != null) {
      classifier.interpreter!.close();
    }
  }

  onSelect(model) async {
    setState(() {
      _busy = true;
      _model = model;
      _recognitions = [];
    });

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

    // Update Count
    _count = _recognitions.length;

    double factorX = _imageWidth / screen.width * screen.width;
    double factorY = _imageWidth / screen.width * screen.width;
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
            "${(re.id + 1).toStringAsFixed(0)}",
            style: TextStyle(
              background: Paint()..color = blue,
              color: Colors.red,
              fontSize: re.id == length - 1 ? 14.0 : 10,
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
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: 384,
      height: 384,
      child: _image == null ? Text('No image selected.') : Image.file(_image!),
    ));
    stackChildren.addAll(renderBoxes(size));

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
          title:
              Text((_recognitions.length.toString() ?? "0") + " Pills Counted"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Add To Report',
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String? pillReportString = prefs.getString('pillcounts');
                final String? currentCount = prefs.getString('currentCount');
                PillInformation pillInfo =
                    PillInformation.fromJson(jsonDecode(currentCount!));
                pillInfo.count = _count;
                List<PillInformation> pillReport = pillReportString != null
                    ? PillInformation.decode(pillReportString)
                    : List.filled(1, pillInfo, growable: true);
                if (!pillReport.contains(pillInfo)) {
                  if (pillReport.length >= 1) {
                    pillReport.add(pillInfo);
                  }
                }
                final String result = PillInformation.encode(pillReport);
                prefs.setString('pillcounts', (result));
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SessionReport()));
              },
            ),
          ]),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var camera = await loadCamera();
          var image = await Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (context) => TakePictureScreen(camera: camera)));
          if (image != null) {
            dev.log("made it back");
            predictImage(File(image.path));
          }
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
