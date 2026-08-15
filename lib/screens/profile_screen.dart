import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/income_settings.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';
import 'income_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _pulledRemote = false;
  bool _signingIn = false;
  bool _isSignUp = false;
  bool _submittingPassword = false;
  bool _showAuthForm = false;
  String? _authError;
  String? _authNotice;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    setState(() => _showAuthForm = false);
  }

  void _submitPassword(AuthService auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _authError = '이메일과 비밀번호를 입력해주세요';
        _authNotice = null;
      });
      return;
    }
    setState(() {
      _submittingPassword = true;
      _authError = null;
      _authNotice = null;
    });
    try {
      if (_isSignUp) {
        final res = await auth.signUpWithPassword(
          email: email,
          password: password,
        );
        if (res.session == null && mounted) {
          setState(() => _authNotice = '가입 확인 메일을 보냈어요. 메일함을 확인해주세요');
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) {
      setState(() => _authError = e.message);
    } finally {
      if (mounted) setState(() => _submittingPassword = false);
    }
  }

  Widget _buildLoggedInCard(AuthService auth) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primarySoft,
          child: Text(
            (auth.currentUser?.email ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(
                color: AppColors.primaryDark, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 12, color: AppColors.mint),
                  const SizedBox(width: 4),
                  const Text('안전하게 백업 중',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                auth.currentUser?.email ?? '',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10),
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
    );
  }

  Widget _buildAuthPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock_outline_rounded,
                  size: 16, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('로그인하고 내 정보 지키기',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 2),
                  const Text('로그인하지 않아도 이 기기에서는 계속 사용할 수 있어요',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => setState(() => _showAuthForm = true),
          child: const Text('로그인 / 회원가입'),
        ),
      ],
    );
  }

  Widget _buildAuthForm(AuthService auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(_isSignUp ? '회원가입' : '로그인',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            InkWell(
              onTap: () => setState(() {
                _showAuthForm = false;
                _authError = null;
                _authNotice = null;
              }),
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close_rounded,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: '이메일'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: '비밀번호'),
        ),
        if (_authError != null) ...[
          const SizedBox(height: 6),
          Text(_authError!,
              style: const TextStyle(color: AppColors.coral, fontSize: 10)),
        ],
        if (_authNotice != null) ...[
          const SizedBox(height: 6),
          Text(_authNotice!,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
        const SizedBox(height: 8),
        FilledButton(
          onPressed:
              _submittingPassword ? null : () => _submitPassword(auth),
          child: _submittingPassword
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(_isSignUp ? '회원가입' : '로그인'),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => setState(() {
            _isSignUp = !_isSignUp;
            _authError = null;
            _authNotice = null;
          }),
          child: Text(_isSignUp ? '이미 계정이 있으신가요? 로그인' : '계정이 없으신가요? 회원가입'),
        ),
        const SizedBox(height: 6),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('또는',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 6),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final auth = context.watch<AuthService>();
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            const Text('내 프로필',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            SoftCard(
              child: auth.isLoggedIn
                  ? _buildLoggedInCard(auth)
                  : (_showAuthForm
                      ? _buildAuthForm(auth)
                      : _buildAuthPrompt()),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IncomeSettingsScreen()),
              ),
              child: SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('💰', style: TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('월급 · 시급',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            '${appState.income.type == IncomeType.hourly ? '시급' : '월급'} ${formatKoreanUnit(appState.income.amount)}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('절약 vs 지출',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: saveRatio,
                      minHeight: 10,
                      backgroundColor: AppColors.coral.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(AppColors.mint),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    denom > 0
                        ? '아낀 돈이 전체의 ${(saveRatio * 100).round()}%예요'
                        : '아직 기록이 없어요',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (spendingByCategory.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('카테고리별 지출',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: spendingByCategory.entries.map((e) {
                    final ratio = totalSpent > 0 ? e.value / totalSpent : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(e.key.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(e.key.label,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(formatKoreanUnit(e.value),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
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
              const SizedBox(height: 16),
              const Text('최근 지출 내역',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              ...recentPurchases.map((item) => Container(
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
                            color: item.category.color.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(item.category.emoji,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(item.category.label,
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                        Text(formatKoreanUnit(item.price),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                Text(label,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
