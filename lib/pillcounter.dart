import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:pillcounter_flutter/recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'classifier.dart';
import 'camerawidgets.dart';
import 'report.dart';

const String model = "model";
enum pointColour { red, blue, pink, green }

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
  bool _firstVisit = false;
  double _slidesize = 14;
  pointColour? _colour = pointColour.blue;

  @override
  void initState() {
    super.initState();
    _firstVisit = true;
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
        dev.log(
            "info.image.height is" + info.image.height.toDouble().toString());
        dev.log(
            "info.image.height is" + info.image.width.toDouble().toString());
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
    _count = _recognitions.length;
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    // Update Count
    _count = _recognitions.length;

    double factorX = _imageWidth / 384;
    double factorY = _imageHeight / 384;
    var length = _recognitions.length;
    Color clr = getColour(_colour);
    return _recognitions.map((re) {
      Rect rec = re.renderLocation;
      return Positioned(
        left: (rec.left + rec.left + rec.width - _slidesize) / 2,
        top: (rec.top + rec.top + rec.height - _slidesize) / 2,
        height: _slidesize,
        width: _slidesize,
        child: GestureDetector(
          onTap: () {
            _recognitions.remove(re);
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: clr,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  showCamera() async {
    var camera = await loadCamera();
    var image = await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
            builder: (context) => TakePictureScreen(camera: camera)));
    if (image != null) {
      dev.log("made it back");
      setState(() {
        _firstVisit = false;
        _image = null;
        _recognitions = [];
        _busy = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () async {
        await predictImage(File(image.path));
      });
    }
  }

  void onTapEvent(BuildContext context, TapDownDetails details) {
    //print('${details.globalPosition}');
    final RenderObject? box = context.findRenderObject();
    if (box is RenderBox) {
      final Offset localOffset = box.globalToLocal(details.localPosition);
      setState(() {
        _recognitions.add(Recognition(
            _recognitions.length,
            "pill",
            1,
            Rect.fromCenter(
                center: localOffset.translate(0, 0), width: 10, height: 10)));
      });
    }
  }

  Color getColour(pointColour? colour) {
    Color clr = Colors.blue;
    switch (colour) {
      case pointColour.red:
        clr = Colors.red;
        break;
      case pointColour.blue:
        clr = Colors.blue;
        break;
      case pointColour.pink:
        clr = Colors.pink.shade900;
        break;
      case pointColour.green:
        clr = Colors.green;
        break;
      default:
        break;
    }
    return clr;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackChildren = [];
    if (_firstVisit) {
      showCamera();
    }
    if (_busy) {
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    } else {}

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: 384,
      height: 384,
      child: _image == null
          ? Text('')
          : GestureDetector(
              onTapDown: (TapDownDetails details) =>
                  onTapEvent(context, details),
              child: Image.file(_image!,
                  height: 384, width: 384, fit: BoxFit.fill)),
    ));
    stackChildren.addAll(renderBoxes(size));

    return Scaffold(
      appBar: AppBar(
          title: Text((_count.toString()) + " Pills Counted"),
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
      body: Column(children: <Widget>[
        SizedBox(
            child: Stack(
              children: stackChildren,
            ),
            width: 384,
            height: 384),
        const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            "Point Size",
            style: TextStyle(fontSize: 18),
          ),
        ),

        Container(
            alignment: Alignment.bottomLeft,
            child: Slider(
                min: 6.0,
                max: 32.0,
                value: _slidesize,
                onChanged: (value) {
                  setState(() {
                    _slidesize = value;
                  });
                })),
        const Text(
          "Point Colour",
          style: TextStyle(fontSize: 18),
        ),

        Row(children: <Widget>[
          Expanded(
              child: Radio<pointColour>(
            value: pointColour.red,
            groupValue: _colour,
            onChanged: (pointColour? value) {
              setState(() {
                _colour = value;
              });
            },
            fillColor: MaterialStateColor.resolveWith((states) => Colors.red),
          )),
          Expanded(
              child: Radio<pointColour>(
            value: pointColour.blue,
            groupValue: _colour,
            onChanged: (pointColour? value) {
              setState(() {
                _colour = value;
              });
            },
            fillColor: MaterialStateColor.resolveWith((states) => Colors.blue),
          )),
          Expanded(
              child: Radio<pointColour>(
            value: pointColour.pink,
            groupValue: _colour,
            onChanged: (pointColour? value) {
              setState(() {
                _colour = value;
              });
            },
            fillColor: MaterialStateColor.resolveWith(
                (states) => Colors.pink.shade900),
          )),
          Expanded(
            child: Radio<pointColour>(
              value: pointColour.green,
              groupValue: _colour,
              onChanged: (pointColour? value) {
                setState(() {
                  _colour = value;
                });
              },
              fillColor:
                  MaterialStateColor.resolveWith((states) => Colors.green),
            ),
          )
        ])

        // Row(children: <Widget>[
        //   Expanded(
        //     child: ListView(shrinkWrap: true, children: <Widget>[
        //       ListTile(
        //           leading: Radio<pointColour>(
        //         value: pointColour.red,
        //         groupValue: _colour,
        //         onChanged: (pointColour? value) {
        //           setState(() {
        //             _colour = value;
        //           });
        //         },
        //         fillColor:
        //             MaterialStateColor.resolveWith((states) => Colors.red),
        //       ))
        //     ]),
        //   ),
        //   Expanded(
        //     child: ListView(shrinkWrap: true, children: <Widget>[
        //       ListTile(
        //           leading: Radio<pointColour>(
        //         value: pointColour.blue,
        //         groupValue: _colour,
        //         onChanged: (pointColour? value) {
        //           setState(() {
        //             _colour = value;
        //           });
        //         },
        //         fillColor:
        //             MaterialStateColor.resolveWith((states) => Colors.blue),
        //       ))
        //     ]),
        //   ),
        //   Expanded(
        //     child: ListView(shrinkWrap: true, children: <Widget>[
        //       ListTile(
        //           leading: Radio<pointColour>(
        //         value: pointColour.yellow,
        //         groupValue: _colour,
        //         onChanged: (pointColour? value) {
        //           setState(() {
        //             _colour = value;
        //           });
        //         },
        //         fillColor:
        //             MaterialStateColor.resolveWith((states) => Colors.yellow),
        //       ))
        //     ]),
        //   ),
        //   Expanded(
        //     child: ListView(shrinkWrap: true, children: <Widget>[
        //       ListTile(
        //           leading: Radio<pointColour>(
        //         value: pointColour.green,
        //         groupValue: _colour,
        //         onChanged: (pointColour? value) {
        //           setState(() {
        //             _colour = value;
        //           });
        //         },
        //         fillColor:
        //             MaterialStateColor.resolveWith((states) => Colors.green),
        //       ))
        //     ]),
        //   ),
        //   Expanded(
        //     child: ListView(shrinkWrap: true, children: <Widget>[
        //       ListTile(
        //           leading: Radio<pointColour>(
        //         value: pointColour.pink,
        //         groupValue: _colour,
        //         onChanged: (pointColour? value) {
        //           setState(() {
        //             _colour = value;
        //           });
        //         },
        //         fillColor:
        //             MaterialStateColor.resolveWith((states) => Colors.pink),
        //       ))
        //     ]),
        //   ),
        // ])
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showCamera();
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
