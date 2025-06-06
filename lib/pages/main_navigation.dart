import 'package:flutter/material.dart';
import 'package:responsiah/pages/home_page.dart';
import 'package:responsiah/pages/search_page.dart';
import 'package:responsiah/pages/love_page.dart';
import 'package:responsiah/pages/profile_page.dart';
import 'package:responsiah/pages/sensor_page.dart';
import 'package:responsiah/services/session_service.dart';
import 'dart:io';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final Color primaryColor = const Color(0xFFAEDFF7); // pastel blue

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const SensorPage(),
    const LovePage(),
    const ProfilePage(),
  ];

  Widget _buildProfileIcon(bool isSelected) {
    final user = SessionService.currentUser;

    if (user?.profileImagePath != null && user!.profileImagePath!.isNotEmpty) {
      final imageFile = File(user.profileImagePath!);
      if (imageFile.existsSync()) {
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[600]!,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.file(
              imageFile,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    // Fallback to default icon if no profile image
    return Icon(
      isSelected ? Icons.person : Icons.person_outline,
      size: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Cari',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.sensor_door_outlined),
              activeIcon: Icon(Icons.sensor_door),
              label: 'Sensor',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Love',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(false),
              activeIcon: _buildProfileIcon(true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
