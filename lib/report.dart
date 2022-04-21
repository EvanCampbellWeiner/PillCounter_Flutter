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

void updatePillInformationList(
    List<PillInformation> pillInformationList) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('pillcounts', PillInformation.encode(pillInformationList));
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
            title: const Text(
              'Session Report',
              // 2
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.delete_forever_outlined,
                    color: Colors.red),
                tooltip: 'Delete Session Report',
                onPressed: () {
                  List<PillInformation> empty = [];
                  updatePillInformationList(empty);
                },
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
