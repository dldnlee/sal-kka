enum IncomeType { monthly, hourly }

class IncomeSettings {
  final IncomeType type;
  final double amount;

  const IncomeSettings({required this.type, required this.amount});

  Map<String, dynamic> toJson() => {'type': type.name, 'amount': amount};

  factory IncomeSettings.fromJson(Map<String, dynamic> json) =>
      IncomeSettings(
        type: IncomeType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => IncomeType.hourly,
        ),
        amount: (json['amount'] as num).toDouble(),
      );

  static const defaultSettings =
      IncomeSettings(type: IncomeType.hourly, amount: 10030);
}
