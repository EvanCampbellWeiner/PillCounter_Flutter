import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pillinformation.dart';
import 'package:http/io_client.dart' as io;
import 'dart:developer' as dev;

Future<List<dynamic>> createPillInformationList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? pillReportString = prefs.getString('pillcounts');
  final List<dynamic> pillReport =
      PillInformation.decode(pillReportString ?? "");
  return pillReport;
}

// Generate a list of pill Informations asynchronously.
// Add 12 pill Informations to pillInformationList, waiting for a response
// before adding them each time.
//
// Future<List<PillInformation>> createPillInformationList() async {
//   List<PillInformation> pillInformationList = [];
//   final pillDins = [
//     "00000019",
//     "00000175",
//     "00000213",
//     "00000396",
//     "00000485",
//     "00000604",
//     "00000655",
//     "00001120",
//     "00001147",
//     "00001686",
//     "00001341",
//   ];
//
// // Holds title of pillInformation List
//   pillInformationList.add(PillInformation(description: "Name", din: "DIN"));
//
//   for (int i = 0; i < pillDins.length; i++) {
//     pillInformationList
//         .add(await fetchPillInformation(pillDins[i], io.IOClient()));
//   }
//
//   return pillInformationList;
// }

class SessionReport extends StatefulWidget {
  SessionReport({Key? key}) : super(key: key);

  @override
  _SessionReportState createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
  static const int numItems = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Session Report',
          // 2
        ),
        centerTitle: true,
      ),
      body: Center(
          child: (FutureBuilder<List<dynamic>>(
        future: createPillInformationList(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (!snapshot.hasData) {
              return Text("no data");
            } else {
              return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  // if (index == 0){
                  // return ListTile(
                  //   title: Text(snapshot.data[index].description),
                  //   subtitle: Text(snapshot.data[index].din),
                  //   trailing: Row(children: <Widget>[
                  //     Text(snapshot.data[index].count),
                  //   ],)
                  // );
                  // }
                  return ListTile(
                    title: Text(snapshot.data[index].description),
                    subtitle: Text(snapshot.data[index].din),
                    trailing: Text(snapshot.data[index].count.toString()),
                    onTap: () {
                      PillInformation tapped = PillInformation(
                        din: snapshot.data[index].din,
                        description: snapshot.data[index].description,
                        count: snapshot.data[index].count,
                      );
                      ScreenArguments toPass = ScreenArguments(tapped, index);
                      //final SharedPreferences prefs = await SharedPreferences.getInstance();
                      //prefs.setString('index',index.toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PillInformationReview(),
                            settings:
                                RouteSettings(arguments: toPass)),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: snapshot.data.length,
              );
            }
          }
        },
      )) // Child
          ),
    );
  }
}
