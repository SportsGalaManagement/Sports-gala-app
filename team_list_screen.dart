import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final bool isAdmin;
  final String category; // 🔹 Step 1: Category receive karne ke liye field

  const TeamListScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.isAdmin,
    required this.category, // 🔹 Constructor mein add kiya
  });

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  final CollectionReference _teamsCollection =
  FirebaseFirestore.instance.collection('teams');

  // 🔹 Dynamic Dialog (Aapki original logic)
  void _showTeamDialog({DocumentSnapshot? document}) {
    TextEditingController teamNameController = TextEditingController();
    TextEditingController captainController = TextEditingController();
    List<TextEditingController> memberControllers = [];

    if (document != null) {
      teamNameController.text = document['teamName'];
      captainController.text = document['captain'] == "N/A" ? "" : document['captain'];
      List existingMembers = document['members'] ?? [];
      for (var m in existingMembers) {
        memberControllers.add(TextEditingController(text: m.toString()));
      }
    } else {
      memberControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(document == null ? "Register Entry" : "Edit Details"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogField(
                      teamNameController,
                      "Team or Player Name",
                      Icons.emoji_events_outlined,
                      "e.g. Eleven Stars or Ahmed Ali"
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                      captainController,
                      "Captain Name (Optional)",
                      Icons.person_pin_outlined,
                      "Keep empty for Singles/Doubles"
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                          "Players / Members",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2671))
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1D2671)),
                        onPressed: () => setDialogState(() => memberControllers.add(TextEditingController())),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...memberControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: memberControllers[index],
                              decoration: InputDecoration(
                                labelText: "Player ${index + 1}",
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          if (memberControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              onPressed: () => setDialogState(() => memberControllers.removeAt(index)),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Text(
                    "* Use + to add more players for team games.",
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2671),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                List<String> membersList = memberControllers
                    .map((c) => c.text.trim())
                    .where((text) => text.isNotEmpty)
                    .toList();

                if (teamNameController.text.isNotEmpty && membersList.isNotEmpty) {
                  // 🔹 Step 2: 'category' field yahan save ho rahi hai (Backend ke liye)
                  var data = {
                    'teamName': teamNameController.text.trim(),
                    'captain': captainController.text.trim().isEmpty ? "N/A" : captainController.text.trim(),
                    'members': membersList,
                    'eventId': widget.eventId,
                    'category': widget.category, // 🔥 Ye Performance Screen filter ke liye hai
                    'lastUpdated': FieldValue.serverTimestamp(),
                  };

                  if (document == null) {
                    await _teamsCollection.add(data);
                  } else {
                    await _teamsCollection.doc(document.id).update(data);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Entry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Aapka original Helper Widget
  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1D2671)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("${widget.eventName} Entries", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        onPressed: () => _showTeamDialog(),
        label: const Text("Register", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
      )
          : null,
      body: StreamBuilder(
        stream: _teamsCollection.where('eventId', isEqualTo: widget.eventId).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text("No entries registered yet", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var team = snapshot.data!.docs[index];
              List members = team['members'] ?? [];
              String captain = team['captain'] ?? "N/A";

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: Icon(
                        members.length > 1 ? Icons.groups_rounded : Icons.person_rounded,
                        color: primaryBlue, size: 22
                    ),
                  ),
                  title: Text(team['teamName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Text(captain == "N/A" ? "Individual Entry" : "Captain: $captain"),
                  trailing: widget.isAdmin
                      ? IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () => _showOptionsBottomSheet(team),
                  )
                      : null,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.02),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            members.length > 1 ? "Team Players:" : "Player Detail:",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: members.map((m) => Chip(
                              label: Text(m.toString(), style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: primaryBlue.withOpacity(0.1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // BottomSheet logic
  void _showOptionsBottomSheet(DocumentSnapshot team) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: Colors.blue),
              title: const Text("Edit Entry"),
              onTap: () {
                Navigator.pop(context);
                _showTeamDialog(document: team);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              title: const Text("Delete Entry"),
              onTap: () {
                team.reference.delete();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
