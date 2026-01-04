import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'points_matches_list.dart';

class PointsScreen extends StatefulWidget {
  final bool isAdmin;
  const PointsScreen({super.key, required this.isAdmin});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  String selectedCategory = "Boys";
  final Color primaryBlue = const Color(0xFF1D2671);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Points Table", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                _buildCategoryButton("Boys"),
                _buildCategoryButton("Girls"),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  return doc['category'] == selectedCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text("No $selectedCategory events found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var event = filteredDocs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text(event['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PointsMatchesList(
                                eventName: event['name'],
                                category: selectedCategory,
                                isAdmin: widget.isAdmin,
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title) {
    bool isActive = selectedCategory == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$title Matches",
              style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
