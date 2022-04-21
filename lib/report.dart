import 'dart:developer';
import 'dart:math';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pillinformation.dart';
import 'package:http/io_client.dart' as io;
import 'dart:developer' as dev;

///
/// UpdatePillInformationList
///
Future<List<PillInformation>> createPillInformationList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? pillReportString = prefs.getString('pillcounts');
  final List<PillInformation> pillReport =
      PillInformation.decode(pillReportString ?? "");
  return pillReport;
}

Future<List<PillInformation>> createBackupList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? backupReportString = prefs.getString('backup');
  final List<PillInformation> backupReport =
      PillInformation.decode(backupReportString ?? "");
  return backupReport;
}

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
  bool _archive =
      false; // Used to determine if there is a deleted report stored.(changes color and func. of undo)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: (IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Session Report',
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Deleting Report"),
                  content: const Text(
                      "Are you sure you want to delete the session report?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        DeleteReport(context);
                        _archive = true;
                        setState(() {});
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ),
            )),
            title: const Text(
              'Session Report',
              // 2
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Recover Deleted Session Report',
                color: !_archive ? Colors.grey : Colors.white,
                onPressed: !_archive
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Recover Report"),
                            content: const Text(
                                "Are you sure you want to recover the deleted report? This will overwrite the current session."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  RecoverReport(context);
                                  _archive = false;
                                  setState(() {});
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        ),
              ),
              IconButton(
                icon: const Icon(Icons.drive_folder_upload),
                tooltip: 'Export Session Report',
                onPressed: () {
                  dev.log("export report");
                },
              )
            ]),
        // body: Center(
        //     child: ListView.separated(
        //   itemBuilder: (BuildContext context, int index) {
        //     final item = widget.pillInfo[index];
        //     return Dismissible(
        //       key: Key((item.din.toString() +
        //           widget.rand.nextInt(10000).toString())),
        //       onDismissed: (direction) {
        //         setState(() {
        //           if (widget.pillInfo.length > 1) {
        //             widget.pillInfo.removeAt(index);
        //           }
        //         });
        //         updatePillInformationList(widget.pillInfo);
        //       },
        //       child: ListTile(
        //         title: Text(item.description),
        //         subtitle: Text(item.din),
        //         trailing: Text(item.count.toString()),
        //         onTap: () {
        //           PillInformation tapped = PillInformation(
        //             din: item.din,
        //             description: item.description,
        //             count: item.count,
        //           );
        //           ScreenArguments toPass = ScreenArguments(tapped, index);
        //           //final SharedPreferences prefs = await SharedPreferences.getInstance();
        //           //prefs.setString('index',index.toString());
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => PillInformationReview(),
        //                 settings: RouteSettings(arguments: toPass)),
        //           );
        //         },
        //       ),
        //     );
        //   },
        //   separatorBuilder: (context, index) {
        //     return const Divider();
        //   },
        //   itemCount: widget.pillInfo.length,
        // )),
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

// Called when the user clicks "Yes" in the deletion dialog window
DeleteReport(BuildContext context) async {
  // Get the session data that we are deleting
  List<PillInformation> backupSession = await createPillInformationList();
  // Delete it
  List<PillInformation> empty = [];
  updatePillInformationList(empty);
  // Display snackbar at the bottom
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text("Session Report Deleted")));
  // Saving the session to be deleted in prefs['backup']
  updateBackup(backupSession);

  // This needs to change the flag (_archive), before the setState() is called,
  // so that the button to undo can change colors and functionality.
}

// Called when the user clicks "Recover" in the recovert dialog window
RecoverReport(BuildContext context) async {
  // Getting the list of pills from backup report
  List<PillInformation> recovered = await createBackupList();
  // Emptying the backup
  List<PillInformation> empty = [];
  updateBackup(empty);
  // Changing the current session to be the same as that backup
  updatePillInformationList(recovered);
  // Display snackbar at bottom
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text("Session Report Recovered")));
}
