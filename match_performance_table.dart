import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchPerformanceTable extends StatelessWidget {
  final String teamName;
  final String gameName;
  final String category; // 🔹 Gender filter ke liye
  final bool isAdmin;

  MatchPerformanceTable({
    super.key,
    required this.teamName,
    required this.gameName,
    required this.category, // 🔹 Added in constructor
    required this.isAdmin
  });

  final Color primaryBlue = const Color(0xFF1D2671);

  void _showPerfDialog(BuildContext context, {DocumentSnapshot? doc}) {
    TextEditingController pController = TextEditingController();
    TextEditingController wController = TextEditingController();
    TextEditingController lController = TextEditingController();
    TextEditingController ptsController = TextEditingController();

    if (doc != null) {
      pController.text = doc['played'].toString();
      wController.text = doc['won'].toString();
      lController.text = doc['lost'].toString();
      ptsController.text = doc['points'].toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Update Stats", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(pController, "Total Played", Icons.sports_score),
              _buildField(wController, "Won Matches", Icons.emoji_events),
              _buildField(lController, "Loss Matches", Icons.cancel_outlined),
              _buildField(ptsController, "Overall Score / Points", Icons.star_rate_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () async {
              var data = {
                'teamName': teamName,
                'gameName': gameName,
                'category': category, // 🔹 SAVING CATEGORY
                'played': pController.text,
                'won': wController.text,
                'lost': lController.text,
                'points': ptsController.text,
              };
              if (doc == null) {
                await FirebaseFirestore.instance.collection('team_performances').add(data);
              } else {
                await FirebaseFirestore.instance.collection('team_performances').doc(doc.id).update(data);
              }
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("$teamName Stats ($category)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => _showPerfDialog(context),
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: StreamBuilder(
        // 🔹 FILTERING BY TEAM, GAME, AND CATEGORY
        stream: FirebaseFirestore.instance.collection('team_performances')
            .where('teamName', isEqualTo: teamName)
            .where('gameName', isEqualTo: gameName)
            .where('category', isEqualTo: category) // 🔹 Fixed Mix Issue
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No Data Recorded"));

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Official Performance Table - $category", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  DataTable(
                    headingRowColor: MaterialStateProperty.all(primaryBlue.withOpacity(0.1)),
                    border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    columns: [
                      const DataColumn(label: Text('Total Played', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Won', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Loss', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Points', style: TextStyle(fontWeight: FontWeight.bold))),
                      if (isAdmin) const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: snapshot.data!.docs.map((doc) {
                      return DataRow(cells: [
                        DataCell(Text(doc['played'].toString())),
                        DataCell(Text(doc['won'].toString())),
                        DataCell(Text(doc['lost'].toString())),
                        DataCell(Text(doc['points'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (isAdmin) DataCell(
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showPerfDialog(context, doc: doc)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
