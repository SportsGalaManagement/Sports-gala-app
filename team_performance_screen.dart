import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_games_list.dart';

class TeamPerformanceScreen extends StatefulWidget {
  final bool isAdmin;
  const TeamPerformanceScreen({super.key, required this.isAdmin});

  @override
  State<TeamPerformanceScreen> createState() => _TeamPerformanceScreenState();
}

class _TeamPerformanceScreenState extends State<TeamPerformanceScreen> {
  String selectedTab = "Boys";
  final Color primaryBlue = const Color(0xFF1D2671);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Team Performances", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            ),
            child: Row(
              children: [
                _buildTab("Boys"),
                _buildTab("Girls"),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('teams')
                  .where('category', isEqualTo: selectedTab).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var allTeams = snapshot.data!.docs;

                // 🔹 FIX: Duplicate Team Names ko filter karne ka logic
                final seenNames = <String>{};
                final uniqueTeams = allTeams.where((doc) {
                  final name = doc['teamName'] as String;
                  if (seenNames.contains(name)) {
                    return false; // Agar ye naam pehle aa chuka hai to dobara mat dikhao
                  } else {
                    seenNames.add(name); // Pehli baar aaya hai to list mein rakho
                    return true;
                  }
                }).toList();

                if (uniqueTeams.isEmpty) {
                  return Center(child: Text("No $selectedTab teams found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: uniqueTeams.length,
                  itemBuilder: (context, index) {
                    String tName = uniqueTeams[index]['teamName'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: primaryBlue.withOpacity(0.1),
                            child: Icon(Icons.groups, color: primaryBlue)
                        ),
                        title: Text(tName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TeamGamesList(
                                teamName: tName,
                                isAdmin: widget.isAdmin,
                                category: selectedTab
                            )
                        )),
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

  Widget _buildTab(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(10)
          ),
          child: Center(
              child: Text(title,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)
              )
          ),
        ),
      ),
    );
  }
}
