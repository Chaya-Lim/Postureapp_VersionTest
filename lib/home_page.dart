import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'calibration_page.dart';
import 'settings_page.dart'; // 👈 เพิ่ม

class HomePage extends StatefulWidget {
  final String deviceName;

  const HomePage({super.key, required this.deviceName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    DashboardPage(deviceName: widget.deviceName),
    CalibrationPage(deviceName: widget.deviceName),
    SettingsPage(deviceName: widget.deviceName), // 👈 เพิ่ม
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[selectedIndex],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF6E9F8D),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              label: "Calibration",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}