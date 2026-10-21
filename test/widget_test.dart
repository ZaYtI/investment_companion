import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/app.dart';

void main() {
  testWidgets("l'application démarre", (tester) async {
    await tester.pumpWidget(const InvestmentCompanionApp());

    expect(find.text(InvestmentCompanionApp.title), findsOneWidget);
  });
}
