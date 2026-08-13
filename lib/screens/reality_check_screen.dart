import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
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
      appBar: AppBar(title: const Text('🚨 팩트 폭격 리포트 🚨')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '"$name (${formatKoreanUnit(price)})을 사려면..."',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _MetricRow(
                emoji: '⏰',
                label: '내 노동 시간',
                value: '${reality.hours}시간 ${reality.minutes}분 일해야 함',
              ),
              _MetricRow(
                emoji: '🍗',
                label: '치킨 지수',
                value: '치킨 ${reality.chickenCount}마리 안 먹는 셈',
              ),
              _MetricRow(
                emoji: '☕',
                label: '스타벅스',
                value: '아메리카노 ${reality.coffeeCount}잔 꼴',
              ),
              const SizedBox(height: 12),
              Text(
                '💬 "이 돈이면 당근마켓에 더 싸게 나와있지 않을까?"',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _openDaangnSearch,
                icon: const Text('🥕'),
                label: const Text('당근에서 중고 시세 검색해보기'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _shareToFriends,
                icon: const Text('💬'),
                label: const Text('친구한테 살까 말까 물어보기'),
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 12),
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

class _MetricRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _MetricRow(
      {required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
