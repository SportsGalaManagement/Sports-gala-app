import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'match_performance_table.dart';

class TeamGamesList extends StatelessWidget {
  final String teamName;
  final String category;
  final bool isAdmin;

  const TeamGamesList({
    super.key,
    required this.teamName,
    required this.isAdmin,
    required this.category
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("$teamName - $category Games"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        // 🔹 Filter: Sirf wahi games (events) dikhayen jo is category ki hain
        stream: FirebaseFirestore.instance
            .collection('events')
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
                  Icon(Icons.sports_esports_outlined, size: 60, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  Text("No games found for $category.",
                      style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var game = snapshot.data!.docs[index];
              String gameName = game['name'];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: const Icon(Icons.sports_soccer, color: primaryBlue),
                  ),
                  title: Text(
                      gameName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  subtitle: const Text("View match performance & stats"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchPerformanceTable(
                          teamName: teamName,
                          gameName: gameName,
                          category: category, // 🔹 PASSING CATEGORY TO PERFORMANCE TABLE
                          isAdmin: isAdmin,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
