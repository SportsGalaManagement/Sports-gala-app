import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultMatchesList extends StatelessWidget {
  final String eventName;
  final String category;
  final bool isAdmin;

  const ResultMatchesList({
    super.key,
    required this.eventName,
    required this.category,
    required this.isAdmin
  });

  // 🔹 Result Manage karne ka Dialog (Add/Update/Delete)
  void _showResultDialog(BuildContext context, DocumentSnapshot matchDoc) {
    TextEditingController winnerController = TextEditingController();
    TextEditingController scoreController = TextEditingController();

    Map<String, dynamic>? data = matchDoc.data() as Map<String, dynamic>?;
    winnerController.text = (data != null && data.containsKey('winner')) ? data['winner'] : '';
    scoreController.text = (data != null && data.containsKey('score')) ? data['score'] : '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Announce Result", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2671).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "${matchDoc['mainTeamName']}  VS  ${matchDoc['opponent']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2671)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: winnerController,
              decoration: InputDecoration(
                labelText: "Winner Team Name",
                prefixIcon: const Icon(Icons.workspace_premium),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: scoreController,
              decoration: InputDecoration(
                labelText: "Final Score / Remarks",
                hintText: "e.g. 120/5 or Won by 2 goals",
                prefixIcon: const Icon(Icons.assessment_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")
          ),
          if (data != null && data.containsKey('winner'))
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('schedules').doc(matchDoc.id).update({
                  'winner': FieldValue.delete(),
                  'score': FieldValue.delete(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Delete Result", style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D2671),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              if (winnerController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('schedules').doc(matchDoc.id).update({
                  'winner': winnerController.text.trim(),
                  'score': scoreController.text.trim(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text("Save Result", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("$eventName Results ($category)"),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text("No matches scheduled to show results.", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var match = snapshot.data!.docs[index];
              Map<String, dynamic> data = match.data() as Map<String, dynamic>;
              bool hasResult = data.containsKey('winner') && data['winner'].toString().isNotEmpty;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: hasResult ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      child: Icon(
                        hasResult ? Icons.workspace_premium : Icons.pending_actions_rounded,
                        color: hasResult ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(
                      "${match['mainTeamName']} VS ${match['opponent']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: hasResult
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Winner: ${match['winner']}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          Text("Score: ${match['score']}", style: const TextStyle(fontSize: 13)),
                        ],
                      )
                          : const Text("Result Pending...", style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                    trailing: isAdmin
                        ? IconButton(
                      icon: Icon(
                        hasResult ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                        color: primaryBlue,
                        size: 30,
                      ),
                      onPressed: () => _showResultDialog(context, match),
                    )
                        : null,
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
