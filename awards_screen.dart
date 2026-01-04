import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AwardsScreen extends StatefulWidget {
  final bool isAdmin;
  const AwardsScreen({super.key, required this.isAdmin});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  String selectedCategory = "Boys";
  final Color primaryBlue = const Color(0xFF1D2671);
  final CollectionReference _awardsCollection = FirebaseFirestore.instance.collection('awards');

  void _showAwardDialog(BuildContext context, {DocumentSnapshot? doc}) {
    TextEditingController titleController = TextEditingController(text: doc != null ? doc['title'] : "");
    TextEditingController winnerController = TextEditingController(text: doc != null ? doc['winner'] : "");
    TextEditingController teamController = TextEditingController(text: doc != null ? doc['team'] : "");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(doc == null ? "Add $selectedCategory Award" : "Edit Award"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleController, "Award Title (e.g. Best Player)"),
              _buildTextField(winnerController, "Winner Name"),
              _buildTextField(teamController, "Team Name"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () async {
              if (titleController.text.isEmpty || winnerController.text.isEmpty) return;

              var data = {
                'title': titleController.text,
                'winner': winnerController.text,
                'team': teamController.text,
                'category': selectedCategory,
                'timestamp': doc == null ? DateTime.now().millisecondsSinceEpoch : doc['timestamp'],
              };

              if (doc == null) {
                await _awardsCollection.add(data);
              } else {
                await _awardsCollection.doc(doc.id).update(data);
              }
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Tournament Awards", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
        onPressed: () => _showAwardDialog(context),
        backgroundColor: primaryBlue,
        child: const Icon(Icons.workspace_premium, color: Colors.white),
      )
          : null,
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
                _buildCategoryTab("Boys"),
                _buildCategoryTab("Girls"),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              // 🔹 FIX: Yahan 'category' filter lagaya hai aur timestamp handling fix ki hai
              stream: _awardsCollection
                  .where('category', isEqualTo: selectedCategory)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No $selectedCategory awards yet."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                        title: Text(doc['title'], style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                        subtitle: Text("Winner: ${doc['winner']}\nTeam: ${doc['team']}"),
                        trailing: widget.isAdmin
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAwardDialog(context, doc: doc)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
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

  Widget _buildCategoryTab(String title) {
    bool isSelected = selectedCategory == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}
