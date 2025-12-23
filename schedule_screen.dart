import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Match Schedule")),
      body: ListView(
        children: [
          scheduleTile("CS Tigers vs SE Lions", "10 Jan", "2 PM"),
          scheduleTile("IT Hawks vs EE Stars", "11 Jan", "4 PM"),
        ],
      ),
    );
  }

  Widget scheduleTile(String match, String date, String time) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(Icons.schedule),
        title: Text(match),
        subtitle: Text("$date • $time"),
      ),
    );
  }
}
