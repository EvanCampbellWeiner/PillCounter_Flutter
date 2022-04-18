import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'report.dart';
import 'main.dart';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:image_picker/image_picker.dart';

/**
   Take Picture Screen Class | 
   Purpose: Constructs and Contains the Take Picture Screen state and has the camera instantiation
 */
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

/**
 * TakePictureScreenState | 
 * Purpose: A screen that allows users to take a picture using a given camera.
 */
class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _cameraController.initialize();
  }

/**
 * dispose() | 
 * Purpose: Invoked when we have finished using the camera.
 */
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

/**
 * Returns a Scaffold to provide basic visual layout, contains the feed from the
 * camera and a FloatingActionButton which takes the photo.
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Picture'),
        centerTitle: true,
          actions: <Widget>[
            IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Select Image',
            onPressed: () {
                var _picker = ImagePicker();
                var image = null;
                try {
                  image = _picker.pickImage(
                      source: ImageSource.gallery,
                      maxHeight: 5000,
                      maxWidth: 5000,
                      imageQuality: 75);
                  if (image == null) return;
                } catch (e) {
                  setState(() {
                    print(e);
                  });
                }
                Navigator.pop(context, image);
            },
          ),
        ]
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_cameraController);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _cameraController.takePicture();
            dev.log("Trying to pop");
            // If the picture was taken, display it on a new screen.
            Navigator.pop(context, image);
          } catch (e) {
            // If an error occurs, log the error to the console.
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

/**
 * DisplayPictureScreen Class
 * Purpose: Contructs and contains the state for DisplayPictureScreen
 */
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreen();
}

// A widget that displays the picture taken by the user.
/**
 * DisplayPictureScreen | 
 * Creates a widget that presents the user with the image they have
 * taken as well as the option to continue, or retake the image.
 */
class _DisplayPictureScreen extends State<DisplayPictureScreen> {
  int _selectedIndex = 0;

  // Accesses the array of BottomNavigationBarItems to
  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SessionReport()),
        );
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Review Image'),
          centerTitle: true,
        ),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Image.file(File(widget.imagePath)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              // Index = 0
              icon: Icon(Icons.edit),
              label: 'Retake Image',
            ),
            BottomNavigationBarItem(
              // Index = 1
              icon: Icon(Icons.arrow_forward),
              label: 'Count',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ));
  }
}
