import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';

class RealityCheckScreen extends StatelessWidget {
  final String name;
  final double price;
  final Category category;
  final double hourlyWage;

  const RealityCheckScreen({
    super.key,
    required this.name,
    required this.price,
    required this.category,
    required this.hourlyWage,
  });

  Future<void> _openDaangnSearch() async {
    final uri = Uri.parse(
        'https://www.daangn.com/kr/buy-sell/?in=&search=${Uri.encodeComponent(name)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareToFriends() async {
    await Share.share(
      '나 이거 [$name] 살까 말까? 투표해줘! 🤔\n'
      '가격: ${formatKoreanUnit(price)}',
    );
  }

  void _holdOff(BuildContext context) async {
    final appState = context.read<AppState>();
    final now = DateTime.now();
    final item = ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      price: price,
      category: category,
      hourlyWage: hourlyWage,
      createdAt: now,
      cooldownEndsAt: now.add(const Duration(hours: 72)),
      status: ItemStatus.cooling,
    );
    await appState.addItem(item);
    if (!context.mounted) return;
    appState.goToTab(1);
    Navigator.of(context).pop();
  }

  void _buyNow(BuildContext context) async {
    final appState = context.read<AppState>();
    final now = DateTime.now();
    final item = ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      price: price,
      category: category,
      hourlyWage: hourlyWage,
      createdAt: now,
      cooldownEndsAt: now,
      status: ItemStatus.bought,
      decisionAt: now,
    );
    await appState.addItem(item);
    if (!context.mounted) return;
    appState.goToTab(2);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final reality = computeReality(price, hourlyWage);

    return Scaffold(
      appBar: AppBar(title: const Text('🚨 팩트 폭격 리포트')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '"$name (${formatKoreanUnit(price)})을 사려면..."',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '⏰',
                      color: const Color(0xFF7FB8FF),
                      label: '내 노동 시간',
                      value: '${reality.hours}시간\n${reality.minutes}분',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      emoji: '🍗',
                      color: const Color(0xFFFFB37B),
                      label: '치킨 지수',
                      value: '${reality.chickenCount}마리',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      emoji: '☕',
                      color: AppColors.mint,
                      label: '스타벅스',
                      value: '${reality.coffeeCount}잔',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SoftCard(
                color: AppColors.mintSoft,
                shadow: const [],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '💬 "이 돈이면 당근마켓에 더 싸게 나와있지 않을까?"',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _openDaangnSearch,
                      icon: const Text('🥕'),
                      label: const Text('당근에서 중고 시세 검색해보기'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _shareToFriends,
                      icon: const Text('💬'),
                      label: const Text('친구한테 살까 말까 물어보기'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => _holdOff(context),
                child: const Text('🔥 72시간만 참아보기 ⏳'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _buyNow(context),
                child: const Text('지름신 강림... 그냥 살래 💸'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.emoji,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
