import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results")),
      body: ListView(
        children: [
          resultTile("CS vs SE", "CS Tigers", "120/4"),
          resultTile("IT vs EE", "IT Hawks", "2-1"),
        ],
      ),
    );
  }

  Widget resultTile(String match, String winner, String score) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(Icons.emoji_events),
        title: Text(match),
        subtitle: Text("Winner: $winner • Score: $score"),
      ),
    );
  }
}
