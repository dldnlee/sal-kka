import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/income_settings.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class IncomeSettingsScreen extends StatefulWidget {
  const IncomeSettingsScreen({super.key});

  @override
  State<IncomeSettingsScreen> createState() => _IncomeSettingsScreenState();
}

class _IncomeSettingsScreenState extends State<IncomeSettingsScreen> {
  final _incomeController = TextEditingController();
  IncomeType _incomeType = IncomeType.hourly;
  bool _initialized = false;
  bool _saved = false;

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final auth = context.watch<AuthService>();
    _syncFromState(appState);

    return Scaffold(
      appBar: AppBar(title: const Text('월급 · 시급 설정')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('💰  월급 또는 시급이 얼마예요?',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 3),
                const Text('상품 가격을 노동 시간으로 환산할 때 사용돼요',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 10)),
                const SizedBox(height: 10),
                SegmentedButton<IncomeType>(
                  segments: const [
                    ButtonSegment(
                        value: IncomeType.hourly, label: Text('시급')),
                    ButtonSegment(
                        value: IncomeType.monthly, label: Text('월급')),
                  ],
                  selected: {_incomeType},
                  onSelectionChanged: (s) =>
                      setState(() => _incomeType = s.first),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _incomeType == IncomeType.hourly
                        ? '시급 (원)'
                        : '월급 (원)',
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => _save(appState, auth),
                  child: Text(_saved ? '저장됐어요 ✅' : '저장하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
