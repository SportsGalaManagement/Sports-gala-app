import 'package:flutter/material.dart';
import 'add_event_screen.dart';

class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Events")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen()));
        },
      ),
      body: ListView(
        children: [
          eventTile("Cricket", "Boys", "Main Ground"),
          eventTile("Football", "Girls", "Ground B"),
        ],
      ),
    );
  }

  Widget eventTile(String name, String category, String venue) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(Icons.sports),
        title: Text(name),
        subtitle: Text("$category • $venue"),
      ),
    );
  }
}
