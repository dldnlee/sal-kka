import 'package:intl/intl.dart';
import '../models/income_settings.dart';

const double chickenPrice = 22000;
const double coffeePrice = 4500;
const double monthlyToHourlyDivisor = 209; // 주 40시간 + 주휴시간 기준 월 소정근로시간

final _wonFormat = NumberFormat.decimalPattern('ko_KR');

double toHourlyWage(IncomeSettings income) {
  if (income.type == IncomeType.hourly) return income.amount;
  return (income.amount / monthlyToHourlyDivisor).roundToDouble();
}

String formatWon(num amount) => '${_wonFormat.format(amount)}원';

String formatKoreanUnit(num amount) {
  if (amount >= 10000) {
    final man = amount / 10000;
    final rounded =
        man == man.roundToDouble() ? man.round() : (man * 10).round() / 10;
    return '${_wonFormat.format(rounded)}만원';
  }
  return formatWon(amount);
}

class RealityCheck {
  final int hours;
  final int minutes;
  final int chickenCount;
  final int coffeeCount;

  const RealityCheck({
    required this.hours,
    required this.minutes,
    required this.chickenCount,
    required this.coffeeCount,
  });
}

RealityCheck computeReality(double price, double hourlyWage) {
  final totalHours = hourlyWage > 0 ? price / hourlyWage : 0.0;
  var hours = totalHours.floor();
  var minutes = ((totalHours - hours) * 60).round();
  if (minutes == 60) {
    hours += 1;
    minutes = 0;
  }
  final chickenCount = (price / chickenPrice).round().clamp(1, 999999);
  final coffeeCount = (price / coffeePrice).round().clamp(1, 999999);
  return RealityCheck(
    hours: hours,
    minutes: minutes,
    chickenCount: chickenCount,
    coffeeCount: coffeeCount,
  );
}
