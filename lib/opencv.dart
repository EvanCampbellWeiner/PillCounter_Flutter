import 'dart:typed_data';

import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'dart:async';
import 'dart:io';
//import 'package:image/image.dart'; //image dependency 2.0.5 is incompatible with google_fonts
import 'package:image_picker/image_picker.dart';

//Left to implement:
//Cv2.blur(pathString: pathString, kernelSize: kernelSize, anchorPoint: anchorPoint, borderType: borderType)

/* 
await file.readAsBytes() --> for image?

*/

Future<Uint8List?> dilateImage([kern_size = 3]) async {
  Uint8List? _byte = await Cv2.dilate(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    kernelSize: [kern_size, kern_size],
  );

  return _byte;
}

Future<Uint8List?> erodeImage([kern_size = 3]) async {
  Uint8List? _byte = await Cv2.erode(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    kernelSize: [kern_size, kern_size],
  );

  return _byte;
}

Future<Uint8List?> thresholdImage(
    {val = 150, maxval = 200, threshtype = Cv2.THRESH_BINARY}) async {
  Uint8List? _byte = await Cv2.threshold(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    thresholdValue: val,
    maxThresholdValue: maxval,
    thresholdType: threshtype,
  );

  return _byte;
}

Future<Uint8List?> medianBlur([kern_size = 5]) async {
  Uint8List? _byte = await Cv2.medianBlur(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    kernelSize: kern_size,
  );

  return _byte;
}

/* 
pyrMSFilter()

Definition: applies opencv pyramidMeanShiftFiltering function to an image

Params:
spatial_rad -> specifies spatial filtering radius. Default=5. 
color_rad -> specifies color filtering radius. Default=5.

Example Usage: 


See https://docs.opencv.org/3.4/d4/d86/group__imgproc__filter.html for more information.
*/
Future<Uint8List?> pyrMSFilter([spatial_rad = 5, color_rad = 5]) async {
  Uint8List? _byte = await Cv2.pyrMeanShiftFiltering(
    pathFrom: CVPathFrom.ASSETS,
    pathString: 'assets/Test.JPG',
    spatialWindowRadius: spatial_rad,
    colorWindowRadius: color_rad,
  );

  return _byte;
}

/* 
cvtColor()

Definition: applies opencv cvtColor filter to an image. Used to grayscale images. 

Params:
output_type -> specifies filter to apply. Default=Cv2_COLOR_BGR2GRAY. 
See opencv documentation below for more options on color conversions. 

Example Usage: 


See https://docs.opencv.org/3.4/d8/d01/group__imgproc__color__conversions.html for more information.
*/
Future<Uint8List?> cvtColor([output_type = Cv2.COLOR_BGR2GRAY]) async {
  Uint8List? _byte = await Cv2.cvtColor(
    pathFrom: CVPathFrom.ASSETS,
    pathString: 'assets/Test.JPG',
    outputType: output_type,
  );

  return _byte;
}

/*
Function: morphEx() 

Description: Applies a morphological operation to an image.

Params: 
  kern_size -> specifies the kernel size to use. Recommend between 1-5. Default=3.

  op -> morphological operation to apply. Options = Cv2.MORPH_OPEN, Cv2.MORPH_CLOSE, Cv2.MORPH_ERODE, 
  Cv2.MORPH_DILATE, Cv2.MORPH_TOPHAT, Cv2.MORPH_BLACKHAT, Cv2.MORPH_GRADIENT. Default=Cv2.MORH_OPEN

Example usage: 
  Uint8List newImage = morphEx();  -- default 
  Uint8List newImage = morphEx(kern_size: 5, op: Cv2.MORPH_CLOSE); -- specifies a kernel size of 5 and the MORPH_CLOSE operation.

See https://docs.opencv.org/3.4/d9/d61/tutorial_py_morphological_ops.html for more information on opencv morphological operations.   
*/
Future<Uint8List?> morphEx({kern_size = 3, op = Cv2.MORPH_OPEN}) async {
  Uint8List? _byte = await Cv2.morphologyEx(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    operation: op,
    kernelSize: kern_size,
  );

  return _byte;
}

Future<Uint8List?> laplacian([kern_size = 3]) async {
  Uint8List? _byte = await Cv2.laplacian(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    depth: kern_size,
  );

  return _byte;
}

Future<Uint8List?> gaussianBlur([kern_size = 5, sigma_x = 3]) async {
  Uint8List? _byte = await Cv2.gaussianBlur(
      pathFrom: CVPathFrom.ASSETS,
      //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
      pathString: 'assets/Test.JPG',
      kernelSize: kern_size,
      sigmaX: sigma_x);

  return _byte;
}

Future<Uint8List?> distanceTransform(
    [dist_type = Cv2.DIST_L2, mask_size = 3]) async {
  Uint8List? _byte = await Cv2.distanceTransform(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    distanceType: dist_type,
    maskSize: mask_size,
  );

  return _byte;
}

Future<Uint8List?> blur([kern_size = 3]) async {
  Uint8List? _byte = await Cv2.blur(
    pathFrom: CVPathFrom.ASSETS,
    //need to change to CVPathFrom.GALLERY_CAMERA to use image_picker
    pathString: 'assets/Test.JPG',
    kernelSize: kern_size,
    anchorPoint: ,
    borderType: ,
  );

  return _byte;
}





/* 
Can't resolve dependency

Image resizeImage(img, size) {
  Image resize = copyResize(img, size);
  return resize;
}
*/
