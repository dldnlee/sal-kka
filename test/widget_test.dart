import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sal_kka/main.dart';

void main() {
  testWidgets('App boots to the input screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SalKkaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('오늘은 뭘 참아볼까요?'), findsOneWidget);
    expect(find.text('뭐 사고 싶어요?'), findsOneWidget);

    await tester.tap(find.text('🐷'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('팩폭 리포트 보기 🚨'), findsOneWidget);
  });
}
