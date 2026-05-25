import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'notes/notes_list_screen.dart';
import 'progress/progress_screen.dart';
import 'profile/profile_screen.dart';
import '../core/constants/app_colors.dart';

import '../core/widgets/background_scaffold.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override 
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;
  final _screens = const [
    DashboardScreen(), 
    NotesListScreen(), 
    ProgressScreen(), 
    ProfileScreen()
  ];

  @override 
  void initState() { 
    super.initState(); 
    _index = widget.initialIndex; 
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 12, 
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined), 
            label: 'Notes'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded), 
            label: 'Progress'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded), 
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}
