import 'package:flutter/material.dart';

class SessionReport extends StatefulWidget {
  const SessionReport({Key? key}) : super(key: key);

  @override
  _SessionReportState createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
  static const int numItems = 10;
  List<bool> selected = List<bool>.generate(numItems, (int index) => false);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text('Pill Name'),
          ),
          DataColumn(
            label: Text('Pill Count'),
          ),
        ],
        rows: List<DataRow>.generate(
          numItems,
          (int index) => DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              // All rows will have the same selected color.
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              }
              // Even rows have a gray color.
              if (index.isEven) {
                return Colors.grey.withOpacity(0.3);
              }
              // Use the default value for other states and odd rows.
              return null;
            }),
            cells: <DataCell>[
              DataCell(Text('Row $index')),
              DataCell(Text((index == null ? 0 : index * 10).toString())),
            ],
            selected: selected[index],
            onSelectChanged: (bool? value) {
              setState(() {
                selected[index] = value!;
              });
            },
          ),
        ),
      ),
    );
  }
}
