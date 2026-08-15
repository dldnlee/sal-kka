import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'input_screen.dart';
import 'profile_screen.dart';
import 'vault_screen.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  static const _tabs = [
    (Icons.edit_note_rounded, '입력'),
    (Icons.inventory_2_outlined, '보관소'),
    (Icons.bar_chart_rounded, '정산'),
    (Icons.person_outline, '프로필'),
  ];

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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final (icon, label) = _tabs[i];
                final selected = appState.currentTab == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => appState.goToTab(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 22,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.textMuted),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
