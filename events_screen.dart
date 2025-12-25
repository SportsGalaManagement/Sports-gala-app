import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsScreen extends StatefulWidget {
  final bool isAdmin;
  EventsScreen({this.isAdmin = false});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final CollectionReference events =
  FirebaseFirestore.instance.collection('events');

  String selectedSport = ""; // default filter
  final List<String> sports = ["Football", "Basketball", "Volleyball"];

  bool showSidePanel = false; // toggle side panel

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade400,        // pink
                Color(0xFF8A2BE2),           // purplish blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              setState(() {
                showSidePanel = !showSidePanel;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🔹 Main Event List
          Column(
            children: [
              if (widget.isAdmin)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await events.add({
                        'name': 'New Event',
                        'sport': 'Football',
                      });
                    },
                    icon: Icon(Icons.add),
                    label: Text("Add Event"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                    ),
                  ),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: events.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;

                    // Filter based on selectedSport
                    final filteredDocs = selectedSport == "All"
                        ? docs
                        : docs.where((doc) {
                      final data =
                      doc.data() as Map<String, dynamic>;
                      return data['sport'] == selectedSport;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['sport'] ?? ''),
                          trailing: widget.isAdmin
                              ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              events.doc(filteredDocs[index].id).delete();
                            },
                          )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 🔹 Side Panel
          if (showSidePanel)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.shade200,
                      Colors.pink.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade300.withOpacity(0.5),
                      blurRadius: 8,
                      offset: Offset(-2, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Text(
                        "Filter by Sport",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Divider(color: Colors.white70),
                    ...sports.map((sport) => ListTile(
                      title: Text(
                        sport,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          selectedSport = sport;
                          showSidePanel = false; // close panel
                        });
                      },
                    )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
