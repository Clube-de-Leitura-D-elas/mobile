import 'package:flutter/material.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';

import 'profile_screen.dart'; // Importe o ficheiro da Screen

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: const SafeArea(child: ProfileScreen()),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: QuickAccessItem.profile.index,
        onItemSelected: (index) => context.goToQuickAccessTab(
          index,
          currentIndex: QuickAccessItem.profile.index,
        ),
      ),
    );
  }
}
