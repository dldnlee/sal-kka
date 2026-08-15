import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';
import 'reality_check_screen.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  Category _category = Category.fashion;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit(AppState appState) async {
    if (!_formKey.currentState!.validate()) return;

    final hourlyWage = toHourlyWage(appState.income);
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

    return Scaffold(
      appBar: AppBar(title: const Text('뭐가 사고 싶나요? 🛍️')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '상품명 또는 링크',
                          hintText: '예: 무신사 패딩',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? '상품명을 입력해주세요' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '가격 (원)',
                          hintText: '예: 150000',
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
                      const Text('카테고리',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              fontSize: 10)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Category.values.map((c) {
                          final selected = c == _category;
                          return GestureDetector(
                            onTap: () => setState(() => _category = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: selected
                                    ? c.color
                                    : c.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(c.emoji, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    c.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
