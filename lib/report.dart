import 'package:flutter/material.dart';
import 'package:introduction_to_flutter/pillinformation.dart';
import 'pillinformation.dart';

// Generate a list of pill Informations asynchronously.
// Add 12 pill Informations to pillInformationList, waiting for a response
// before adding them each time.

Future<List<PillInformation>> createPillInformationList() async {
  List<PillInformation> pillInformationList = [];
  final pillDins = [
    "00000019",
    "00000175",
    "00000213",
    "00000396",
    "00000485",
    "00000604",
    "00000655",
    "00001120",
    "00001147",
    "00001686",
    "00001341",
  ];

// Holds title of pillInformation List
  pillInformationList.add(PillInformation(description: "Name", din: "DIN"));

  for (int i = 0; i < pillDins.length; i++) {
    pillInformationList.add(await fetchPillInformation(pillDins[i]));
  }

  return pillInformationList;
}

class SessionReport extends StatefulWidget {
  SessionReport({Key? key}) : super(key: key);

  @override
  _SessionReportState createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
  static const int numItems = 10;
  List<PillInformation> pills = List<PillInformation>.generate(
      numItems,
      (int index) =>
          PillInformation(din: '00000$index', description: 'Pill $index'));

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<PillInformation>>(
        future: createPillInformationList(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (!snapshot.hasData) {
              return Container();
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
                    // trailing: Row(
                    //   children: <Widget>[
                    //     Text(snapshot.data[index].count),
                    //   ],
                    // )
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
      ),
    );
  }
}
