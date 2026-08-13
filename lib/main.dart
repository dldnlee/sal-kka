import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/root_shell.dart';
import 'services/app_state.dart';

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B4A)),
          useMaterial3: true,
          fontFamily: 'NotoSansKR',
        ),
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
