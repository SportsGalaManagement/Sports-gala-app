import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddMatchSchedule extends StatefulWidget {
  final String teamId;
  final String teamName;
  final String eventName;
  final String category;
  final bool isAdmin;

  const AddMatchSchedule({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.eventName,
    required this.category,
    required this.isAdmin
  });

  @override
  State<AddMatchSchedule> createState() => _AddMatchScheduleState();
}

class _AddMatchScheduleState extends State<AddMatchSchedule> {
  final CollectionReference _scheduleCollection = FirebaseFirestore.instance.collection('schedules');

  void _showScheduleDialog({DocumentSnapshot? document}) {
    TextEditingController opponentController = TextEditingController();
    TextEditingController venueController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    if (document != null) {
      opponentController.text = document['opponent'] ?? '';
      venueController.text = document['venue'] ?? '';
      // Purani date/time parse karne ka logic (optional)
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(document == null ? "Schedule Match" : "Update Match"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: opponentController,
                  decoration: InputDecoration(
                    labelText: "Opponent Team",
                    prefixIcon: const Icon(Icons.group_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: venueController,
                  decoration: InputDecoration(
                    labelText: "Venue",
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                // Date Picker Tile
                ListTile(
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text("Date: ${DateFormat('dd-MMM-yyyy').format(selectedDate)}"),
                  trailing: const Icon(Icons.calendar_month, color: Color(0xFF1D2671)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
                const SizedBox(height: 10),
                // Time Picker Tile
                ListTile(
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text("Time: ${selectedTime.format(context)}"),
                  trailing: const Icon(Icons.access_time, color: Color(0xFF1D2671)),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
                    if (picked != null) setDialogState(() => selectedTime = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2671),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (opponentController.text.isNotEmpty && venueController.text.isNotEmpty) {
                  var data = {
                    'mainTeamId': widget.teamId,
                    'mainTeamName': widget.teamName,
                    'eventName': widget.eventName,
                    'category': widget.category,
                    'opponent': opponentController.text,
                    'venue': venueController.text,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'time': selectedTime.format(context),
                    'timestamp': FieldValue.serverTimestamp(),
                  };

                  if (document == null) {
                    await _scheduleCollection.add(data);
                  } else {
                    await _scheduleCollection.doc(document.id).update(data);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Match", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("${widget.teamName}'s Matches"),
        centerTitle: true,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        onPressed: () => _showScheduleDialog(),
        label: const Text("Add Match", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add_task, color: Colors.white),
      )
          : null,
      body: StreamBuilder(
        stream: _scheduleCollection
            .where('mainTeamId', isEqualTo: widget.teamId)
            .where('eventName', isEqualTo: widget.eventName)
            .where('category', isEqualTo: widget.category)
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
                  Icon(Icons.event_note_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text("No matches scheduled for this team.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var match = snapshot.data!.docs[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.sports_score_rounded, color: primaryBlue),
                    ),
                    title: Text(
                      "${widget.teamName} VS ${match['opponent']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(match['venue']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text("${match['date']} | ${match['time']}"),
                          ],
                        ),
                      ],
                    ),
                    trailing: widget.isAdmin
                        ? PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (val) {
                        if (val == 'edit') _showScheduleDialog(document: match);
                        if (val == 'delete') match.reference.delete();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text("Edit")),
                        const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                      ],
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
