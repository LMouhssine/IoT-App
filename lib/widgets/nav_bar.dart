import 'package:flutter/material.dart';
import '../constants.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  
  const NavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.speed),
          label: 'Seuil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppConstants.thresholdRoute);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppConstants.historyRoute);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, AppConstants.settingsRoute);
            break;
        }
      },
    );
  }
} 