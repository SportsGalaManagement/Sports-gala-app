import 'package:flutter/material.dart';
import 'events_screen.dart';
import 'teams_screen.dart';
import 'schedule_screen.dart';
import 'results_screen.dart';
import 'points_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isAdmin; // Admin vs Guest
  HomeScreen({this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC33764), // pink
              Color(0xFF1D2671), // purple/blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // 🔝 HEADER (CENTERED)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 38,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sports Gala",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ⬜ WHITE CARD AREA
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    children: [
                      dashboardCard(context, "Events", Icons.emoji_events),
                      dashboardCard(context, "Teams", Icons.groups),
                      dashboardCard(context, "Schedule", Icons.schedule),
                      dashboardCard(context, "Results", Icons.score),
                      dashboardCard(context, "Points Table", Icons.table_chart),
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

  // 🔲 DASHBOARD CARD
  Widget dashboardCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == "Events") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventsScreen(isAdmin: isAdmin)),
          );
        } else if (title == "Teams") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TeamsScreen(isAdmin: isAdmin)),
          );
        } else if (title == "Schedule") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ScheduleScreen(isAdmin: isAdmin)),
          );
        } else if (title == "Results") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResultsScreen(isAdmin: isAdmin)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PointsScreen(isAdmin: isAdmin)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.25),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: Color(0xFFC33764),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 10),

            // Admin-only Edit button
            if (isAdmin)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Admin can edit $title!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  "Edit",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
