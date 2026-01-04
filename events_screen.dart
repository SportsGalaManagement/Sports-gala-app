import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsScreen extends StatefulWidget {
  final bool isAdmin;
  const EventsScreen({super.key, required this.isAdmin});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('events');

  // 🔹 Default Category Selection
  String selectedTab = "Boys";

  // 🔹 Function to Show Add/Update Dialog
  void _showEventDialog({DocumentSnapshot? document}) {
    TextEditingController nameController = TextEditingController();
    TextEditingController venueController = TextEditingController();
    String category = selectedTab; // Dialog khulte waqt wahi category select hogi jo bahar hai

    if (document != null) {
      nameController.text = document['name'];
      venueController.text = document['venue'];
      category = document['category'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(document == null ? "Add New Event" : "Update Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Event Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                  items: ['Boys', 'Girls'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => setDialogState(() => category = val!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: "Venue", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2671)),
              onPressed: () async {
                if (nameController.text.isNotEmpty && venueController.text.isNotEmpty) {
                  Map<String, dynamic> eventData = {
                    'name': nameController.text,
                    'category': category,
                    'venue': venueController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  };

                  if (document == null) {
                    await _eventsCollection.add(eventData);
                  } else {
                    await _eventsCollection.doc(document.id).update(eventData);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Events", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showEventDialog(),
      )
          : null,
      body: Column(
        children: [
          // 🔹 CATEGORY TOGGLE BUTTONS (SIDE BY SIDE)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                _buildToggleButton("Boys"),
                _buildToggleButton("Girls"),
              ],
            ),
          ),

          // 🔹 FILTERED EVENTS LIST
          Expanded(
            child: StreamBuilder(
              // Query mein category filter laga diya hai
              stream: _eventsCollection
                  .where('category', isEqualTo: selectedTab)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No $selectedTab Events Found"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8EAF6),
                          child: Icon(Icons.sports_baseball, color: primaryBlue),
                        ),
                        title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Venue: ${doc['venue']}"),
                        trailing: widget.isAdmin
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _showEventDialog(document: doc)),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _eventsCollection.doc(doc.id).delete()),
                          ],
                        )
                            : null,
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

  // 🔹 Helper Widget for Side-by-Side Buttons
  Widget _buildToggleButton(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1D2671) : Colors.transparent,
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
