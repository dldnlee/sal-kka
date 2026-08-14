import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/root_shell.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SalKkaApp());
}

class SalKkaApp extends StatelessWidget {
  const SalKkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: '살까',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AppGate(),
      ),
    );
  }
}

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const RootShell();
  }
}
