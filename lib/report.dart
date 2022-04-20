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

class SessionReport extends StatefulWidget {
  SessionReport({Key? key}) : super(key: key);

  @override
  _SessionReportState createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
  void initState() {
    setState(() {
      () async {
        Future<List<dynamic>> pillL = createPillInformationList();
        List<dynamic> pills = await pillL;
        return pills;
      };
    });
    super.initState();
  }

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
        future: pills,
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
                  final item = snapshot.data[index];
                  return Dismissible(
                    key: Key(item.toString()),
                    onDismissed: (direction) {
                      setState(() {
                        snapshot.data.removeAt(index);
                      });
                      () async {
                        //snapshot.data.removeAt(index);
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        // final String? pillReportString =
                        //     prefs.getString('pillcounts');
                        // final List<dynamic> pillReport =
                        //     PillInformation.decode(pillReportString ?? "");

                        prefs.setString(
                            'pillcounts',
                            PillInformation.encode(
                                snapshot.data as List<PillInformation>));
                      };
                    },
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
                        ScreenArguments toPass = ScreenArguments(tapped, index);
                        //final SharedPreferences prefs = await SharedPreferences.getInstance();
                        //prefs.setString('index',index.toString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PillInformationReview(),
                              settings: RouteSettings(arguments: toPass)),
                        );
                      },
                    ),
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
