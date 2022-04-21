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
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        dev.log("info.image.height is"+info.image.height.toDouble().toString());
        dev.log("info.image.height is"+info.image.width.toDouble().toString());
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
    img.Image? oriImage = img.decodeJpg(imageb);
    img.Image? resizedImage =
        img.copyResize(oriImage!, height: 384, width: 384);
    Classifier classifier = await Classifier();

    await classifier.loadModel();

    var results = await classifier.predict(resizedImage);
    _recognitions = results!;
    if (classifier.interpreter != null) {
      classifier.interpreter!.close();
    }
  }


  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    // Update Count
    _count = _recognitions.length;
    dev.log("Factor X with Image Width is"+_imageWidth.toString());
    dev.log("Factor X with Image Width is"+_imageHeight.toString());

    double factorX = _imageWidth/384;
    double factorY = _imageHeight/384;
    var length = _recognitions.length;
    Color blue = Color.fromRGBO(37, 213, 253, 1.0);
    return _recognitions.map((re) {
      Rect rec = re.renderLocation;
      return Positioned(
        left: (rec.left+rec.left+rec.width-18)/2,
        top: (rec.top+rec.top+rec.height-18)/2,
        height: 18,
        width: 18,
        child: Container(
          decoration: BoxDecoration(
            shape:BoxShape.circle,
            border: Border.all(
              color: blue,
              width: 10,
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: 384,
      height:384,
      child: _image == null ? Text('No image selected.') : Image.file(_image!, height:384, width:384, fit:BoxFit.fill),
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
                  pillReport.add(pillInfo);
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
            predictImage(File(image.path));
          }
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
