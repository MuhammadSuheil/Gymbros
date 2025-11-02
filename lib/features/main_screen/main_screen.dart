import 'package:flutter/material.dart';
import 'package:gymbros/core/constants/app_colors.dart';
import '../../core/widgets/hexagon_clipper.dart';
import '../home/view/home_screen.dart';
import '../history/view/history_screen.dart';
import '../tracking/view/workout_tracking_screen.dart';
import '../streak/view/streak_screen.dart';
import '../profile/view/profile_screen.dart';
import '../../core/widgets/custom_page_route.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    StreakScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
         index: _selectedIndex < 2 ? _selectedIndex : _selectedIndex -1,
         children: _widgetOptions,
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20),
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () {
               Navigator.push(
                context,
                CustomPageRoute(
                  child: const WorkoutTrackingScreen(),
                  direction: AxisDirection.up, 
                ),
              );
            },
            shape: HexagonBorder(side: BorderSide(
                color: AppColors.surface,
                width: 12, 
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            elevation: 4.0,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: SizedBox( 
          height: 60.0, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(Icons.history_outlined, Icons.history, 'History', 1),
              const SizedBox(width: 100), 
              _buildNavItem(Icons.local_fire_department_outlined, Icons.local_fire_department, 'Streak', 2),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconData, IconData activeIconData, String label, int index) {
    int stateIndex = index < 2 ? index : index + 1;
    bool isSelected = _selectedIndex == stateIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(stateIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0), 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  isSelected ? activeIconData : iconData,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 2), 
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1, 
                  overflow: TextOverflow.clip, 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

