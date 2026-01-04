import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'role_selection_screen.dart';
import 'events_screen.dart';
import 'teams_screen.dart';
import 'schedule_screen.dart';
import 'results_screen.dart';
import 'points_screen.dart';
import 'team_performance_screen.dart';
import 'awards_screen.dart';
import 'gallery_screen.dart'; // 🔹 Naya import

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 🔹 App open hote hi Rules dikhane ke liye delay (1 second)
    Future.delayed(const Duration(seconds: 1), () {
      _showRulesDialog();
    });
  }

  // 🔹 Rules & Regulations Popup
  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // 🔹 Isay true rakhein taake bahar click karne se bhi band ho sakay
      builder: (context) => StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('settings').doc('rules_doc').snapshots(),
        builder: (context, snapshot) {
          String rulesText = "Loading rules...";
          if (snapshot.hasData && snapshot.data!.exists) {
            rulesText = snapshot.data!['content'] ?? "No rules available.";
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Container( // 🔹 Stack ko container mein wrap kiya taake size control rahe
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Header Row with Cross Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        constraints: const BoxConstraints(), // Padding khatam karne ke liye
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),

                  const Icon(Icons.gavel_rounded, size: 50, color: Color(0xFF1D2671)),
                  const SizedBox(height: 10),
                  const Text(
                    "Rules & Regulations",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D2671)),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        rulesText,
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  if (widget.isAdmin)
                    TextButton.icon(
                      onPressed: () => _editRules(rulesText),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Update Rules"),
                      style: TextButton.styleFrom(foregroundColor: Colors.amber[900]),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Admin Edit Rules Logic
  void _editRules(String currentRules) {
    TextEditingController rulesController = TextEditingController(text: currentRules);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Rules"),
        content: TextField(
          controller: rulesController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: "Enter rules here...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('settings').doc('rules_doc').set({
                'content': rulesController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);
    const Color accentBlue = Color(0xFF3949AB);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryBlue, accentBlue],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 🔹 HEADER SECTION
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isAdmin ? "ADMIN PANEL" : "STUDENT GUEST",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              "Dashboard",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amber, size: 30),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Text(
                              "Sports Gala 2026 Management",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.white70),
                            onPressed: () => _showRulesDialog(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 DASHBOARD GRID
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: GridView.count(
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _dashboardCard(context, "Events", Icons.emoji_events_outlined, Colors.orange),
                      _dashboardCard(context, "Teams", Icons.groups_outlined, Colors.blue),
                      _dashboardCard(context, "Schedule", Icons.calendar_today_outlined, Colors.teal),
                      _dashboardCard(context, "Results", Icons.query_stats_rounded, Colors.green),
                      _dashboardCard(context, "Points Table", Icons.leaderboard_outlined, Colors.purple),
                      _dashboardCard(context, "Performances", Icons.speed_rounded, Colors.redAccent),
                      _dashboardCard(context, "Awards", Icons.workspace_premium_rounded, Colors.amber[700]!),
                      _dashboardCard(context, "Gallery", Icons.collections_outlined, Colors.pinkAccent), // 🔹 Added Gallery
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(BuildContext context, String title, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () {
        Widget nextScreen;
        switch (title) {
          case "Events": nextScreen = EventsScreen(isAdmin: widget.isAdmin); break;
          case "Teams": nextScreen = TeamsScreen(isAdmin: widget.isAdmin); break;
          case "Schedule": nextScreen = ScheduleScreen(isAdmin: widget.isAdmin); break;
          case "Results": nextScreen = ResultsScreen(isAdmin: widget.isAdmin); break;
          case "Points Table": nextScreen = PointsScreen(isAdmin: widget.isAdmin); break;
          case "Awards": nextScreen = AwardsScreen(isAdmin: widget.isAdmin); break;
          case "Gallery": nextScreen = GalleryScreen(isAdmin: widget.isAdmin); break; // 🔹 Navigation Link
          default: nextScreen = TeamPerformanceScreen(isAdmin: widget.isAdmin);
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D2671).withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2671),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
