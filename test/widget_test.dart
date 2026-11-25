import 'package:flutter_test/flutter_test.dart';
import 'package:greenleaf/data/repositories/plant_repository.dart';
import 'package:greenleaf/main.dart';

void main() {
  testWidgets(
      'GreenLeaf loads plants, logs watering, shows details, and opens Add Plant',
      (WidgetTester tester) async {
    final repository = InMemoryPlantRepository();

    await tester.pumpWidget(GreenLeafApp(repository: repository));
    await tester.pumpAndSettle();

    // Home screen shows brand and today's due plants
    expect(find.text('greenleaf'), findsOneWidget);
    expect(find.text('Money Plant'), findsOneWidget);

    // Tap Watered on the first due plant and verify happy message + watering_log row
    await tester.tap(find.text('Watered').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Yay!'), findsOneWidget);

    final logs = await repository.fetchWateringLog('plant-1');
    expect(logs, hasLength(1));

    // Switch to My Plants tab and verify all 8 sample plants exist
    await tester.tap(find.text('My Plants'));
    await tester.pumpAndSettle();
    expect(find.text('8'), findsOneWidget);

    // Tap a plant card to open Plant Details and verify Watering Log section
    await tester.tap(find.text('Money Plant').first);
    await tester.pumpAndSettle();
    expect(find.text('Plant Details'), findsOneWidget);
    expect(find.text('Care Tip'), findsOneWidget);
    expect(find.text('Watering Log'), findsOneWidget);

    // Go back and switch to Add Plant tab
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Plant'));
    await tester.pumpAndSettle();
    expect(find.text('Add Plant to GreenLeaf'), findsOneWidget);
  });
}
