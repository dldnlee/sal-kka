import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../services/gamification.dart';
import '../theme/app_theme.dart';
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
    final level = appState.levelInfo;
    final unlockedIds = appState.unlockedBadges.map((b) => b.id).toSet();

    if (appState.savedCount > _lastSavedCount) {
      _lastSavedCount = appState.savedCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    } else {
      _lastSavedCount = appState.savedCount;
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                const Text('오늘도 잘 하고 있어요 ✨',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x337B6EF6),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('내가 아낀 총 금액',
                          style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        formatKoreanUnit(appState.totalSaved),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(level.emoji, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text('Lv.${level.level} ${level.title}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: level.progress(appState.totalSaved).toDouble(),
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.mint),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.nextFloor == null
                            ? '최고 레벨을 달성했어요! 👑'
                            : '다음 레벨까지 ${formatKoreanUnit(level.nextFloor! - appState.totalSaved)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        emoji: '🔥',
                        color: AppColors.coral,
                        value: '${appState.currentStreak}',
                        label: '연속 참기',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                        emoji: '🎉',
                        color: AppColors.mint,
                        value: '${appState.savedCount}',
                        label: '총 참은 횟수',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('나의 배지',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allBadges.map((badge) {
                    final unlocked = unlockedIds.contains(badge.id);
                    return _BadgeChip(badge: badge, unlocked: unlocked);
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text('기록',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text('아직 기록이 없어요',
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                  )
                else
                  ...history.map((item) {
                    final saved = item.status == ItemStatus.saved;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: softShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (saved ? AppColors.mint : AppColors.coral)
                                  .withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(saved ? '🎉' : '💸',
                                style: const TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.category.emoji} ${item.category.label} · ${formatKoreanUnit(item.price)}',
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (saved ? AppColors.mint : AppColors.coral)
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              saved ? '참았다!' : '샀다',
                              style: TextStyle(
                                color: saved
                                    ? const Color(0xFF1F9C77)
                                    : const Color(0xFFD9603F),
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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

class _MiniStat extends StatelessWidget {
  final String emoji;
  final Color color;
  final String value;
  final String label;

  const _MiniStat({
    required this.emoji,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style:
                      const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final BadgeDef badge;
  final bool unlocked;

  const _BadgeChip({required this.badge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.gold.withValues(alpha: 0.16) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: unlocked
              ? null
              : Border.all(color: AppColors.primarySoft, width: 1.5),
        ),
        child: Column(
          children: [
            Opacity(
              opacity: unlocked ? 1 : 0.3,
              child: Text(badge.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 4),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: unlocked ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
