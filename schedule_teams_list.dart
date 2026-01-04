import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_match_schedule.dart';

class ScheduleTeamsList extends StatelessWidget {
  final String eventName;
  final String category;
  final bool isAdmin;

  const ScheduleTeamsList({
    super.key,
    required this.eventName,
    required this.category,
    required this.isAdmin
  });

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
        // Step 1: Pehle Event ID dhoondte hain
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('name', isEqualTo: eventName)
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No event details found"));
          }

          String actualEventId = eventSnapshot.data!.docs.first.id;

          return StreamBuilder(
            // Step 2: Us Event ID ki saari Teams dhoondte hain
            stream: FirebaseFirestore.instance
                .collection('teams')
                .where('eventId', isEqualTo: actualEventId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> teamSnapshot) {
              if (teamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!teamSnapshot.hasData || teamSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_rounded, size: 70, color: Colors.grey.withOpacity(0.4)),
                      const SizedBox(height: 10),
                      Text("No teams registered for $eventName", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      "Select a Team to Schedule",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: teamSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var team = teamSnapshot.data!.docs[index];
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
                              child: const Icon(Icons.shield_rounded, color: primaryBlue, size: 24),
                            ),
                            title: Text(
                                team['teamName'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                            subtitle: Text("Captain: ${team['captain']}"),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddMatchSchedule(
                                    teamId: team.id,
                                    teamName: team['teamName'],
                                    eventName: eventName,
                                    category: category,
                                    isAdmin: isAdmin,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
