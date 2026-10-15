import 'package:flutter/material.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';
import 'package:mobile/design_system/widgets/app_bottom_navigation_bar.dart';

class QuickAccessPlaceholderScreen extends StatelessWidget {
  final QuickAccessItem item;

  const QuickAccessPlaceholderScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: item.index,
        onItemSelected: (index) =>
            context.goToQuickAccessTab(index, currentIndex: item.index),
      ),
    );
  }
}
