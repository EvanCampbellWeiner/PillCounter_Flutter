import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pillcounter_flutter/pillinformation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pillinformation.dart';
import 'package:http/io_client.dart' as io;
import 'dart:developer' as dev;

updatePillInformationList(List<PillInformation> list) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
 prefs.setString('pillcounts', PillInformation.encode(list));
}

class SessionReport extends StatefulWidget {
  List<PillInformation> pillInfo;
  Random rand = Random();

  SessionReport({Key? key, required this.pillInfo}) : super(key: key);

  @override
  _SessionReportState createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
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
          child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final item = widget.pillInfo[index];
                  return Dismissible(
                    key: Key((item.din.toString()+ widget.rand.nextInt(10000).toString())),
                    onDismissed: (direction) {
                      setState(() {
                        if(widget.pillInfo.length > 1) {
                          widget.pillInfo.removeAt(index);
                          dev.log("hi");
                        }
                      });
                      updatePillInformationList(widget.pillInfo);
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
                itemCount: widget.pillInfo.length,
              ))
    );
  }
}
