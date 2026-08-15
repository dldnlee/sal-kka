import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'dashboard_screen.dart';
import 'input_screen.dart';
import 'profile_screen.dart';
import 'vault_screen.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final screens = [
      const InputScreen(),
      const VaultScreen(),
      const DashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[appState.currentTab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: NavigationBar(
              height: 64,
              selectedIndex: appState.currentTab,
              onDestinationSelected: appState.goToTab,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.edit_note), label: '입력'),
                NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined), label: '보관소'),
                NavigationDestination(
                    icon: Icon(Icons.bar_chart_rounded), label: '정산'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline), label: '프로필'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
