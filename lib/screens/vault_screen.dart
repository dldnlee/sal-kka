import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  Timer? _ticker;
  late final List<Offset> _starOffsets;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    final rand = Random(7);
    _starOffsets = List.generate(
        24, (_) => Offset(rand.nextDouble(), rand.nextDouble()));
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
      backgroundColor: AppColors.night,
      appBar: AppBar(
        backgroundColor: AppColors.night,
        foregroundColor: Colors.white,
        title: const Text('잠시, 멈춰볼까요 🌙',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Stack(
        children: [
          ..._starOffsets.map((o) => Positioned(
                left: o.dx * MediaQuery.of(context).size.width,
                top: o.dy * MediaQuery.of(context).size.height,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              )),
          SafeArea(
            child: items.isEmpty
                ? const Center(
                    child: Text('🌙 아직 보관 중인 아이템이 없어요',
                        style: TextStyle(color: Colors.white70)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final remaining =
                          item.cooldownEndsAt.difference(DateTime.now());
                      final isDue = remaining.isNegative;
                      final total = item.cooldownEndsAt
                          .difference(item.createdAt)
                          .inSeconds;
                      final elapsed = DateTime.now()
                          .difference(item.createdAt)
                          .inSeconds;
                      final progress =
                          total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.nightCard,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CountdownRing(
                                  progress: progress,
                                  isDue: isDue,
                                  hoursLeft: remaining.isNegative
                                      ? 0
                                      : remaining.inHours,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${item.category.emoji} ${item.category.label} · ${formatKoreanUnit(item.price)}',
                                        style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 10),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isDue
                                            ? '⏰ 고민 끝! 아직도 사고 싶어?'
                                            : _formatRemaining(remaining),
                                        style: TextStyle(
                                          color: isDue
                                              ? AppColors.gold
                                              : Colors.white70,
                                          fontWeight: isDue
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.mint,
                                      minimumSize: const Size.fromHeight(42),
                                    ),
                                    onPressed: () => _resolve(
                                        context, item, ItemStatus.saved),
                                    child: const Text('참았다! 🎉'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.transparent,
                                      side: const BorderSide(
                                          color: Colors.white24, width: 2),
                                      minimumSize: const Size.fromHeight(42),
                                    ),
                                    onPressed: () => _resolve(
                                        context, item, ItemStatus.bought),
                                    child: const Text('샀다 💸'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  final double progress;
  final bool isDue;
  final int hoursLeft;

  const _CountdownRing({
    required this.progress,
    required this.isDue,
    required this.hoursLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                  isDue ? AppColors.gold : AppColors.mint),
            ),
          ),
          isDue
              ? const Text('🔔', style: TextStyle(fontSize: 19))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$hoursLeft',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    const Text('시간',
                        style: TextStyle(color: Colors.white54, fontSize: 9)),
                  ],
                ),
        ],
      ),
    );
  }
}
