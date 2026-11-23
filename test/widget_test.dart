import 'package:finora/app/finora_app.dart';
import 'package:finora/core/di/injection.dart';
import 'package:finora/features/home/presentation/pages/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  testWidgets('renders the home screen at the initial route', (tester) async {
    await tester.pumpWidget(const FinoraApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Finora'), findsOneWidget);
    expect(find.text('Your finances, offline-first.'), findsOneWidget);
  });
}
