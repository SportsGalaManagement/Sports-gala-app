import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StandingsTablePage extends StatelessWidget {
  final String eventName;
  final String category; // 🔹 Gender filter ke liye
  final bool isAdmin;
  final String teamA;
  final String teamB;
  final String matchTime;
  final String winner;
  final String winBy;

  StandingsTablePage({
    super.key,
    required this.eventName,
    required this.category, // 🔹 Constructor mein add kiya
    required this.isAdmin,
    this.teamA = '',
    this.teamB = '',
    this.matchTime = '',
    this.winner = '',
    this.winBy = '',
  });

  final CollectionReference _standingsCollection = FirebaseFirestore.instance.collection('standings');

  void _showStandingDialog(BuildContext context, {DocumentSnapshot? doc}) {
    TextEditingController teamAController = TextEditingController(text: teamA);
    TextEditingController teamBController = TextEditingController(text: teamB);
    TextEditingController timingController = TextEditingController(text: matchTime);
    TextEditingController winnerController = TextEditingController(text: winner);
    TextEditingController winByController = TextEditingController(text: winBy);

    TextEditingController fhA = TextEditingController();
    TextEditingController fhB = TextEditingController();
    TextEditingController shA = TextEditingController();
    TextEditingController shB = TextEditingController();
    TextEditingController wA = TextEditingController();
    TextEditingController wB = TextEditingController();

    if (doc != null) {
      fhA.text = doc['fhA'] ?? "";
      fhB.text = doc['fhB'] ?? "";
      shA.text = doc['shA'] ?? "";
      shB.text = doc['shB'] ?? "";
      wA.text = doc['wicketsA'] ?? "";
      wB.text = doc['wicketsB'] ?? "";
    }

    bool isCricket = eventName.toLowerCase().contains('cricket');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Scorecard"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildPopupField(teamAController, "Team A", readOnly: true),
              _buildPopupField(teamBController, "Team B", readOnly: true),
              _buildPopupField(timingController, "Match Timing", readOnly: true),
              const Divider(),
              _buildHalfRow(fhA, fhB, "1st Half/Innings"),
              _buildHalfRow(shA, shB, "2nd Half/Innings"),
              if (isCricket) _buildHalfRow(wA, wB, "Wickets"),
              const Divider(),
              _buildPopupField(winnerController, "Winner", readOnly: true),
              _buildPopupField(winByController, "Status", readOnly: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D2671)),
            onPressed: () async {
              var data = {
                'eventName': eventName,
                'category': category, // 🔹 Save category
                'teamA': teamAController.text,
                'teamB': teamBController.text,
                'timing': timingController.text,
                'fhA': fhA.text,
                'fhB': fhB.text,
                'shA': shA.text,
                'shB': shB.text,
                'wicketsA': isCricket ? wA.text : "",
                'wicketsB': isCricket ? wB.text : "",
                'winnerName': winnerController.text,
                'winBy': winByController.text,
              };
              if (doc == null) {
                await _standingsCollection.add(data);
              } else {
                await _standingsCollection.doc(doc.id).update(data);
              }
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfRow(TextEditingController c1, TextEditingController c2, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(child: _buildPopupField(c1, "T1 Score")),
            const SizedBox(width: 10),
            Expanded(child: _buildPopupField(c2, "T2 Score")),
          ],
        ),
      ],
    );
  }

  Widget _buildPopupField(TextEditingController controller, String label, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[100] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);
    bool isCricket = eventName.toLowerCase().contains('cricket');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: Text("$eventName ($category) Table"), centerTitle: true),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
        onPressed: () => _showStandingDialog(context),
        label: const Text("Add Stats", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryBlue,
      )
          : null,
      body: StreamBuilder(
        // 🔹 FILTERING BY EVENT AND CATEGORY BOTH
        stream: _standingsCollection
            .where('eventName', isEqualTo: eventName)
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No stats for $category $eventName yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                      child: Text("${doc['teamA']} VS ${doc['teamB']}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    _buildDataRow("TIMING", doc['timing'] ?? "", ""),
                    _buildDataRow("TEAMS", doc['teamA'] ?? "", doc['teamB'] ?? "", isHeader: true),
                    _buildDataRow("1st HALF", doc['fhA'] ?? "", doc['fhB'] ?? ""),
                    _buildDataRow("2nd HALF", doc['shA'] ?? "", doc['shB'] ?? ""),
                    if (isCricket) _buildDataRow("WICKETS", doc['wicketsA'] ?? "0", doc['wicketsB'] ?? "0"),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15))),
                      child: Column(
                        children: [
                          Text("WINNER: ${doc['winnerName']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text("${doc['winBy']}", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isAdmin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showStandingDialog(context, doc: doc)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => doc.reference.delete()),
                        ],
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDataRow(String label, String valA, String valB, {bool isHeader = false}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(10), color: Colors.grey.shade100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
          Expanded(flex: 3, child: Container(padding: const EdgeInsets.all(10), child: Text(valA, textAlign: TextAlign.center, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)))),
          if (valB.isNotEmpty || isHeader)
            Expanded(flex: 3, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade200))), child: Text(valB, textAlign: TextAlign.center, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)))),
        ],
      ),
    );
  }
}
