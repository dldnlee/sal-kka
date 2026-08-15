import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/income_settings.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _incomeController = TextEditingController();
  IncomeType _incomeType = IncomeType.hourly;
  bool _initialized = false;
  bool _saved = false;
  bool _pulledRemote = false;
  bool _signingIn = false;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _syncFromState(AppState appState) {
    if (_initialized) return;
    _incomeType = appState.income.type;
    _incomeController.text = appState.income.amount.toStringAsFixed(0);
    _initialized = true;
  }

  void _maybePullRemoteIncome(AppState appState, AuthService auth) {
    if (!auth.isLoggedIn || _pulledRemote) return;
    _pulledRemote = true;
    auth.fetchIncomeProfile().then((remote) {
      if (remote == null || !mounted) return;
      final type = remote['income_type'] == 'monthly'
          ? IncomeType.monthly
          : IncomeType.hourly;
      final amount = (remote['income_amount'] as num).toDouble();
      appState.setIncome(IncomeSettings(type: type, amount: amount));
      setState(() {
        _incomeType = type;
        _incomeController.text = amount.toStringAsFixed(0);
      });
    });
  }

  void _save(AppState appState, AuthService auth) async {
    final amount = double.tryParse(_incomeController.text.replaceAll(',', ''));
    if (amount == null) return;
    await appState.setIncome(IncomeSettings(type: _incomeType, amount: amount));
    if (auth.isLoggedIn) {
      await auth.saveIncomeProfile(
        incomeType: _incomeType.name,
        incomeAmount: amount,
      );
    }
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _signIn(AuthService auth) async {
    setState(() => _signingIn = true);
    try {
      await auth.signInWithGoogle();
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  void _signOut(AuthService auth) async {
    await auth.signOut();
    _pulledRemote = false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final auth = context.watch<AuthService>();
    _syncFromState(appState);
    _maybePullRemoteIncome(appState, auth);

    final totalSaved = appState.totalSaved;
    final totalSpent = appState.totalSpent;
    final denom = totalSaved + totalSpent;
    final saveRatio = denom > 0 ? totalSaved / denom : 0.0;
    final spendingByCategory = appState.spendingByCategory;
    final recentPurchases = appState.boughtItems.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text('내 프로필',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            SoftCard(
              child: auth.isLoggedIn
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primarySoft,
                          child: Text(
                            (auth.currentUser?.email ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('로그인됨',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(
                                auth.currentUser?.email ?? '',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _signOut(auth),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('로그인하고 내 정보 지키기',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('로그인하지 않아도 이 기기에서는 계속 사용할 수 있어요',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _signingIn ? null : () => _signIn(auth),
                          icon: _signingIn
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('🔎'),
                          label: Text(_signingIn ? '로그인 중...' : 'Google로 계속하기'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('💰  월급 또는 시급이 얼마예요?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('상품 가격을 노동 시간으로 환산할 때 사용돼요',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 14),
                  SegmentedButton<IncomeType>(
                    segments: const [
                      ButtonSegment(value: IncomeType.hourly, label: Text('시급')),
                      ButtonSegment(value: IncomeType.monthly, label: Text('월급')),
                    ],
                    selected: {_incomeType},
                    onSelectionChanged: (s) =>
                        setState(() => _incomeType = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          _incomeType == IncomeType.hourly ? '시급 (원)' : '월급 (원)',
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => _save(appState, auth),
                    child: Text(_saved ? '저장됐어요 ✅' : '저장하기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    emoji: '💸',
                    color: AppColors.coral,
                    value: formatKoreanUnit(totalSpent),
                    label: '총 지출',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    emoji: '🧾',
                    color: const Color(0xFF7FB8FF),
                    value: '${appState.boughtCount}건',
                    label: '지출 횟수',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('절약 vs 지출',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: saveRatio,
                      minHeight: 12,
                      backgroundColor: AppColors.coral.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(AppColors.mint),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    denom > 0
                        ? '아낀 돈이 전체의 ${(saveRatio * 100).round()}%예요'
                        : '아직 기록이 없어요',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (spendingByCategory.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('카테고리별 지출',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: spendingByCategory.entries.map((e) {
                    final ratio = totalSpent > 0 ? e.value / totalSpent : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(e.key.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(e.key.label,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(formatKoreanUnit(e.value),
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: e.key.color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(e.key.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (recentPurchases.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('최근 지출 내역',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              ...recentPurchases.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: item.category.color.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(item.category.emoji,
                              style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(item.category.label,
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(formatKoreanUnit(item.price),
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String emoji;
  final Color color;
  final String value;
  final String label;

  const _StatBlock({
    required this.emoji,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(label,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
