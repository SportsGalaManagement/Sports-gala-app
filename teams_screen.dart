import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_list_screen.dart';

class TeamsScreen extends StatefulWidget {
  final bool isAdmin;
  const TeamsScreen({super.key, required this.isAdmin});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('events');
  String selectedTab = "Boys";
  final Color primaryBlue = const Color(0xFF1D2671);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // 🔹 AppBar Fixed (Blue Background & White Text)
      appBar: AppBar(
        title: const Text("Select Event for Teams",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔹 CATEGORY TOGGLE
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                _buildToggleButton("Boys"),
                _buildToggleButton("Girls"),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: _eventsCollection.where('category', isEqualTo: selectedTab).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No $selectedTab Events Found", style: const TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeamListScreen(
                                eventId: doc.id,
                                eventName: doc['name'],
                                isAdmin: widget.isAdmin,
                                category: selectedTab, // 🔹 Category agay pass kar di
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: primaryBlue.withOpacity(0.1),
                          child: Icon(Icons.sports_soccer, color: primaryBlue),
                        ),
                        title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Venue: ${doc['venue']}"),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$title Matches",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
