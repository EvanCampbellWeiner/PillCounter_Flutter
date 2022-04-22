import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

import 'home.dart';
import 'package:flutter/material.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pillinformation.dart';
import 'package:http/io_client.dart' as io;
import 'dart:developer' as dev;
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';

bool permissionGranted = false;

// createPillInformationList
// Purpose: Used by SessionReport's build() method to read the latest version of
// the Session Report from disk.
//
// Returns: Returns a List of PillInformation objects as a Future
Future<List<PillInformation>> createPillInformationList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? pillReportString = prefs.getString('pillcounts');
  final List<PillInformation> pillReport =
      PillInformation.decode(pillReportString ?? "");
  return pillReport;
}

// updatePillInformationList
// Purpose: Accepts a List of PillInformation objects and writes it to disk as
// the Session Report.
//
// Returns: Nothing
void updatePillInformationList(
    List<PillInformation> pillInformationList) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('pillcounts', PillInformation.encode(pillInformationList));
}

void updateBackup(List<PillInformation> pillInformationList) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('backup', PillInformation.encode(pillInformationList));
}

// class SessionReport extends StatefulWidget {
//   List<PillInformation> pillInfo;
//   Random rand = Random();

//   SessionReport({Key? key, required this.pillInfo}) : super(key: key);

//   @override
//   _SessionReportState createState() => _SessionReportState();
// }

class SessionReport extends StatefulWidget {
  SessionReport({Key? key}) : super(key: key);

  @override
  _SessionReportState createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: (IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Session Report',
              onPressed: () {
                // Get the session data that we are deleting
                Future<List<PillInformation>> backupSession =
                    createPillInformationList();

                // Delete it
                List<PillInformation> empty = [];
                updatePillInformationList(empty);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Session Report Deleted")));

                // Saving the session to be deleted in prefs['backup']
                updateBackup(backupSession as List<PillInformation>);
              },
            )),
            title: const Text(
              'Session Report',
              // 2
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.drive_folder_upload),
                tooltip: 'Export Session Report',
                onPressed: () {
                  dev.log("export report");
                  shareSessionReport();
                },
              )
            ]),
        body: Center(
          child: FutureBuilder<List<PillInformation>>(
            future: createPillInformationList(),
            builder: (BuildContext context,
                AsyncSnapshot<List<PillInformation>> snapshot) {
              Widget children;
              if (snapshot.hasData) {
                // if we have data display it
                children = ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final items = snapshot.data!;
                    final item = items[index];
                    return Dismissible(
                        key: Key(item.din.toString() +
                            (Random().nextInt(10000)).toString()),
                        onDismissed: (direction) {
                          setState(() {
                            items.removeAt(index);
                          });
                          updatePillInformationList(items);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Pill ${item.din} deleted")));
                        },
                        background: Container(color: Colors.red),
                        child: ListTile(
                            title: Text(item.description),
                            subtitle: Text(item.din),
                            trailing: Text(item.count.toString()),
                            onTap: () {
                              PillInformation tapped = PillInformation(
                                din: item.din,
                                description: item.description,
                                count: item.count,
                              );
                              ScreenArguments toPass =
                                  ScreenArguments(tapped, index);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PillInformationReview(),
                                    settings: RouteSettings(arguments: toPass)),
                              );
                            }));
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: snapshot.data!.length,
                );
              } else if (snapshot.hasError) {
                // if there is an error display error
                children = const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                );
              } else {
                // If we have not yet recieved data or an error, show loading circle
                children = const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
              return Center(
                // Do the actual displaying of the widgets
                child: children,
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Home(),
                    settings: RouteSettings()));
          },
          tooltip: 'Add new pill',
          child: Icon(Icons.add),
        ));
  }
}

void shareSessionReport() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.getString('pillcounts');
  final String? pillReportString = prefs.getString('pillcounts');
  final List<PillInformation> pillReport =
      PillInformation.decode(pillReportString ?? "");
  if (await getStoragePermission()) {
    if (Platform.isAndroid) {
      File file = await convertToCSV(pillReport);
      String fileName = file.absolute.toString();
      fileName = fileName.substring(7, fileName.length - 1);
      if (fileName == "") {
        dev.log(
            "Error when exporting Session Report: bad fileName: " + fileName);
      } else if (!(await file.exists())) {
        dev.log("Error when exporting Session Report: File doesn't exist.");
      } else {
        Share.shareFiles([fileName]);
      }
    }
  }
}

Future<File> convertToCSV(List<PillInformation> pillReport) async {
  // Check if the user granted permission
  String fileName = "";
  // To convert to Csv string all values must be in a List<List<dynamic>>
  // Populate the List<List<dynamic>> with values from pillReport
  List<List<dynamic>> _rows = List.generate(
      pillReport.length,
      (index) => index == 0
          ? ["DIN", "Description", "Count"]
          : [
              pillReport[index].din,
              pillReport[index].description,
              pillReport[index].count.toString()
            ]);

  String csv = const ListToCsvConverter().convert(_rows);

  // Store the file
  // Strictly for Android - iOS is differnt.
  // if (Platform.isAndroid) {
  // String directory = ((await getExternalStorageDirectory())!.absolute.toString());

  String directory = (await getTemporaryDirectory()).toString();
  // directory looks like "Directory: 'some/path'" but we want
  // "some/path" so we extract the directory from the string
  directory = directory.substring(12, directory.length - 1);
  DateTime now = DateTime.now();
  String date = "${now.month}-${now.day}-${now.year}";
  fileName = directory + "/SessionReport_" + date + ".csv";
  File file = File(fileName);
  file = await file.writeAsString(csv);
  dev.log("CSV: " + csv);
  final contents = await file.readAsString();
  dev.log("Contents: " + contents);
  return file;
}

Future<bool> getStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    permissionGranted = true;
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  } else if (await Permission.storage.request().isDenied) {
    permissionGranted = false;
  }
  return permissionGranted;
}

// add rand num
// hash

// SR_Date_1
// if there is already a similarly named file, ask if overwrite or new one
