import 'package:flutter/material.dart';

import 'explore_view.dart';
import 'home_view.dart';
import 'profile_view.dart';
import 'trips_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeView(),
    TripsView(),
    ExploreView(),
    ProfileView(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 72,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTabSelected,
            indicatorColor: colorScheme.primary.withOpacity(0.15),
            labelBehavior:
                NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [

              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),

              NavigationDestination(
                icon: Icon(Icons.airplane_ticket_outlined),
                selectedIcon: Icon(Icons.airplane_ticket),
                label: 'Trips',
              ),

              NavigationDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: 'Explore',
              ),

              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),

            ],
          ),
        ),
      ),
    );
  }
}