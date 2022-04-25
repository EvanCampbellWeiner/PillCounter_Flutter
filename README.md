# CountrAI

A Pill Counting Mobile Application built using tflite and flutter.

Checkout the Wiki for more information 

## Background

Created By: 
- Nick Barnes [linkedIn](https://www.linkedin.com/in/nicksbarnes)
- Kyle Burke [linkedin](https://www.linkedin.com/in/kyle-burke-5557a2238/)
- Myles Lee [linkedin](https://www.linkedin.com/in/myles-lee-455497197/)
- Evan Campbell-Weiner [linkedin](https://www.linkedin.com/in/evancampbellweiner/)



## List of Packages that Require Specific Android / iOS Installation

### Camera
Notes:
- Android: requires minSdkVersion 21
- iOS: 
    - check the reference link for installation tutorial
    - requires iOS 10+
Referenced From: Camera[https://pub.dev/packages/camera]

### Permission Handler
Purpose: 
- This is for getting permission to store the exported session. 
Notes: 
- Android:
- iOS: It has very specific installation instructions for Android and iOS. 

Android:
- Make sure the android/app/build.gradle has
```
android {
    compileSdkVersion 31
    ...
}
```
Reference: (Permission Handler)[https://pub.dev/packages/permission_handler]

### Image Picker
Purpose: Allows users to pick an image from their gallery
Notes:
- Android: SDK 21+
- iOS: Requires iOS 9+
    - HEIC images on the iOS simulator in iOS 14+ are not possible to pick (known issue)
    - Need to add keys to the Info.plist file as seen at the link.
  
Reference: (Image Picker)[https://pub.dev/packages/image_picker]

### Share Plus 
Purpose: Export the session report / share it
Notes:
- Will not share to facebook messenger / facebook apps. 
- See reference for more details (known issues)

Reference: (Share Plus)[https://pub.dev/packages/share_plus]

### tflite_flutter
Purpose: Provides support for running the model

Notes:
- Long instructions for installing the dynamic libraries. 
- Android:
- iOS: See the reference for the full installation setup process. 

Last Updated Android: 4/25/2022
Reference: Tflite_Flutter[https://pub.dev/packages/tflite_flutter]



Created For:
- [iApotheca Healthcare](https://iapotheca.com)
- [Trent_University](https://trentu.ca)

