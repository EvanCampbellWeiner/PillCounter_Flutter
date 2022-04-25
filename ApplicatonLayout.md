
# Report.dart 
 ## classes: 
    - SessionReport
    
  ## functions: 
    - createPillInformationList()
    - createBackupList()
    - updatePillInformationList( List<PillInformation> list )
    - updateBackup( List<PillInformation> list )
    - deleteReport( BuildContext c )   
    - recoverReport( BuildContext c )
    - shareSessionReport()
    - convertToCSV( List<PillInformation> list )
    - getStoragePermission()

  
# PillInformation.dart
 ## classes: 
    - PillInformation
    - PillInformationReview
    - DININputForm
    - ScreenArguments
  
 ## functions:
    - fetchPillInformation( String din, http.Client client )

  
# PillCounter.dart
 ## classes: 
    - PillCounter
  
 ## functions: 
    - predictImage( File image ) 
    - runModel( File image )
    - renderBoxes( Size screen )
    - showCamera()
    - onTapEvent( BuildContext c, TapDownDetails details)
    - getColour( pointColour colour )

  
# main.dart
 ## classes: 
    - HomeScreen
   
 ## functions: 
    - main()

  
# tflite/recognition.dart
  ## classes: 
    - Recognition
    - CameraViewSingleton
  

# tflite/classifier.dart
  ## classes: 
     - Classifier
     
  ## functions:
    - loadModel( Interpreter i )
    - loadLabels ( List<String> labels )
    - getProcessedImage( TensorImage image )
    - predict( imageLib.Image img )
  
  
