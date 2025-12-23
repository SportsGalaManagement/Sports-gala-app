import 'package:flutter/material.dart';

class PointsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Points Table")),
      body: DataTable(columns: [
        DataColumn(label: Text("Team")),
        DataColumn(label: Text("Played")),
        DataColumn(label: Text("Points")),
      ], rows: [
        DataRow(cells: [
          DataCell(Text("CS Tigers")),
          DataCell(Text("3")),
          DataCell(Text("6")),
        ]),
        DataRow(cells: [
          DataCell(Text("SE Lions")),
          DataCell(Text("3")),
          DataCell(Text("4")),
        ]),
      ]),
    );
  }
}
