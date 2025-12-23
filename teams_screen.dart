import 'package:flutter/material.dart';

class TeamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teams")),
      body: ListView(
        children: [
          teamTile("CS Tigers", "Computer Science", "Ali"),
          teamTile("SE Lions", "Software Engineering", "Ahmed"),
        ],
      ),
    );
  }

  Widget teamTile(String team, String dept, String captain) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(Icons.group),
        title: Text(team),
        subtitle: Text("$dept • Captain: $captain"),
      ),
    );
  }
}
