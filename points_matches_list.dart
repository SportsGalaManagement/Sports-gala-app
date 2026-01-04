import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'standings_table_page.dart';

class PointsMatchesList extends StatelessWidget {
  final String eventName;
  final String category;
  final bool isAdmin;

  const PointsMatchesList({
    super.key,
    required this.eventName,
    required this.category,
    required this.isAdmin
  });

  void _showPointsDialog(BuildContext context, DocumentSnapshot doc) {
    TextEditingController teamAPoints = TextEditingController();
    TextEditingController teamBPoints = TextEditingController();

    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      teamAPoints.text = data.containsKey('pointsA') ? data['pointsA'].toString() : '';
      teamBPoints.text = data.containsKey('pointsB') ? data['pointsB'].toString() : '';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Enter Match Points", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2671).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${doc['mainTeamName']} vs ${doc['opponent']}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2671)),
              ),
            ),
            const SizedBox(height: 20),
            _buildPointsField(teamAPoints, "${doc['mainTeamName']}"),
            const SizedBox(height: 15),
            _buildPointsField(teamBPoints, "${doc['opponent']}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D2671),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('schedules').doc(doc.id).update({
                'pointsA': teamAPoints.text.trim(),
                'pointsB': teamBPoints.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "$label Points",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("$eventName ($category)"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .where('eventName', isEqualTo: eventName)
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No matches found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var m = snapshot.data!.docs[index];
              Map<String, dynamic> data = m.data() as Map<String, dynamic>;

              String pA = data.containsKey('pointsA') ? data['pointsA'].toString() : '0';
              String pB = data.containsKey('pointsB') ? data['pointsB'].toString() : '0';

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      child: const Icon(Icons.leaderboard_rounded, color: primaryBlue, size: 20),
                    ),
                    title: Text(
                      "${m['mainTeamName']} vs ${m['opponent']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text("Points: $pA - $pB", style: const TextStyle(color: Colors.blueGrey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StandingsTablePage(
                                  eventName: eventName,
                                  category: category, // 🔹 PASSING CATEGORY TO TABLE
                                  isAdmin: isAdmin,
                                  teamA: m['mainTeamName'] ?? 'Team A',
                                  teamB: m['opponent'] ?? 'Team B',
                                  matchTime: m['time'] ?? 'N/A',
                                  winner: data['winner'] ?? '',
                                  winBy: data['score'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: const Text("Table", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, color: Colors.blueGrey),
                            onPressed: () => _showPointsDialog(context, m),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
