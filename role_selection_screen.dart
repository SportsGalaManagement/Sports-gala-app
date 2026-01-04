import 'package:flutter/material.dart';
import 'admin_login_screen.dart';
import 'home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Background ko splash se match karne ke liye halka blue tint diya hai
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Top Brand Icon
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D2671).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_basketball_rounded,
                  size: 60,
                  color: Color(0xFF1D2671),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Welcome Text
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D2671),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select your role to continue the journey",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 50),

              // 🔹 Admin Button (Primary Action)
              _buildRoleButton(
                context,
                title: "Login as Admin",
                subtitle: "Manage events, teams & results",
                icon: Icons.admin_panel_settings_rounded,
                isPrimary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Guest Button (Secondary Action)
              _buildRoleButton(
                context,
                title: "Continue as Guest",
                subtitle: "View schedules & match points",
                icon: Icons.person_outline_rounded,
                isPrimary: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(isAdmin: false)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Professional Button Builder
  Widget _buildRoleButton(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required bool isPrimary,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF1D2671) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: const Color(0xFF1D2671).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? const Color(0xFF1D2671).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isPrimary ? Colors.white.withOpacity(0.2) : const Color(0xFF1D2671).withOpacity(0.1),
              radius: 25,
              child: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF1D2671)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : const Color(0xFF1D2671),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPrimary ? Colors.white70 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: isPrimary ? Colors.white54 : const Color(0xFF1D2671).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
