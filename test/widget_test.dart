import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sal_kka/main.dart';

void main() {
  testWidgets('App boots to the input screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SalKkaApp());
    await tester.pumpAndSettle();

    expect(find.text('살까?'), findsOneWidget);
    expect(find.text('팩폭 리포트 보기 🚨'), findsOneWidget);
  });
}
