import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../utils/calc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ConfettiController _confettiController;
  int _lastSavedCount = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.resolvedItems;

    if (appState.savedCount > _lastSavedCount) {
      _lastSavedCount = appState.savedCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    } else {
      _lastSavedCount = appState.savedCount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('정산')),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('내가 아낀 총 금액',
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(
                        formatKoreanUnit(appState.totalSaved),
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${appState.savedCount}번 참았어요 🎉'),
                    ],
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? const Center(child: Text('아직 기록이 없어요'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: history.length,
                          itemBuilder: (context, i) {
                            final item = history[i];
                            final saved = item.status == ItemStatus.saved;
                            return ListTile(
                              leading: Text(saved ? '🎉' : '💸',
                                  style: const TextStyle(fontSize: 22)),
                              title: Text(item.name),
                              subtitle:
                                  Text('${item.category.label} · ${formatKoreanUnit(item.price)}'),
                              trailing: Text(saved ? '참았다!' : '샀다'),
                            );
                          },
                        ),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
            ),
          ],
        ),
      ),
    );
  }
}
