import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'result_matches_list.dart';

class ResultsScreen extends StatefulWidget {
  final bool isAdmin;
  const ResultsScreen({super.key, required this.isAdmin});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // 🔹 Default Selection
  String selectedCategory = "Boys";
  final Color primaryBlue = const Color(0xFF1D2671);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Match Results"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 PROFESSIONAL CATEGORY TOGGLE (Boys/Girls)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                _categoryButton("Boys"),
                _categoryButton("Girls"),
              ],
            ),
          ),

          // 🔹 DYNAMIC EVENTS LIST
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔹 Filter Logic
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  return doc['category'] == selectedCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics_outlined, size: 70, color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 10),
                        Text("No $selectedCategory events found.",
                            style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var event = filteredDocs[index];
                    String eventName = event['name'];

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: primaryBlue.withOpacity(0.1),
                          child: Icon(Icons.workspace_premium_outlined, color: primaryBlue, size: 24),
                        ),
                        title: Text(
                            eventName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                        ),
                        subtitle: Text("Results for $selectedCategory $eventName"),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultMatchesList(
                                eventName: eventName,
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

  // 🔹 Helper Widget for Category Buttons
  Widget _categoryButton(String title) {
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
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
