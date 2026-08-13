import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../utils/calc.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return '결정 대기 중';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} 남음';
  }

  void _resolve(BuildContext context, ShoppingItem item, ItemStatus status) {
    context.read<AppState>().resolveItem(item.id, status);
    if (status == ItemStatus.saved) {
      context.read<AppState>().goToTab(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final items = appState.coolingItems;

    return Scaffold(
      appBar: AppBar(title: const Text('살까 보관소')),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(child: Text('아직 보관 중인 아이템이 없어요 🌱'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final remaining =
                      item.cooldownEndsAt.difference(DateTime.now());
                  final isDue = remaining.isNegative;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                              '${item.category.label} · ${formatKoreanUnit(item.price)}'),
                          const SizedBox(height: 8),
                          Text(
                            isDue ? '⏰ 고민 끝! 아직도 사고 싶어?' : '🔥 ${_formatRemaining(remaining)}',
                            style: TextStyle(
                              color: isDue
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight:
                                  isDue ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => _resolve(
                                      context, item, ItemStatus.saved),
                                  child: const Text('참았다! 🎉'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _resolve(
                                      context, item, ItemStatus.bought),
                                  child: const Text('샀다 💸'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
