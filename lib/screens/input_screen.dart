import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/income_settings.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../utils/calc.dart';
import 'reality_check_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  IncomeType _incomeType = IncomeType.hourly;
  Category _category = Category.fashion;
  bool _initializedIncome = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _syncIncomeFromState(AppState appState) {
    if (_initializedIncome) return;
    _incomeType = appState.income.type;
    _incomeController.text = appState.income.amount.toStringAsFixed(0);
    _initializedIncome = true;
  }

  void _submit(AppState appState) async {
    if (!_formKey.currentState!.validate()) return;

    final incomeAmount = double.parse(_incomeController.text.replaceAll(',', ''));
    final income = IncomeSettings(type: _incomeType, amount: incomeAmount);
    await appState.setIncome(income);
    final hourlyWage = toHourlyWage(income);

    final price = double.parse(_priceController.text.replaceAll(',', ''));

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RealityCheckScreen(
          name: _nameController.text.trim(),
          price: price,
          category: _category,
          hourlyWage: hourlyWage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _syncIncomeFromState(appState);

    return Scaffold(
      appBar: AppBar(title: const Text('살까?')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('월급 / 시급',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        _incomeType == IncomeType.hourly ? '시급 (원)' : '월급 (원)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '금액을 입력해주세요';
                    if (double.tryParse(v.replaceAll(',', '')) == null) {
                      return '숫자만 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Text('상품 정보', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '상품명 또는 링크',
                    hintText: '예: 무신사 패딩',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '상품명을 입력해주세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '가격 (원)',
                    hintText: '예: 150000',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '가격을 입력해주세요';
                    if (double.tryParse(v.replaceAll(',', '')) == null) {
                      return '숫자만 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Category>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: Category.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => _submit(appState),
                  child: const Text('팩폭 리포트 보기 🚨'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
