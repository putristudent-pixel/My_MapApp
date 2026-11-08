import 'package:flutter_test/flutter_test.dart';
import 'package:my_map_app/main.dart';

void main() {
  testWidgets('home screen opens the destination picker', (tester) async {
    await tester.pumpWidget(const MyMapApp());

    expect(find.text('Hello, Mama Coco!'), findsOneWidget);
    await tester.tap(find.text('Pick a destination'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a place'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
  });

  testWidgets('user can choose a place and start a walk', (tester) async {
    await tester.pumpWidget(const MyMapApp());
    await tester.tap(find.text('Pick a destination'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Park').last);
    await tester.pumpAndSettle();

    expect(find.text('Going to Park'), findsOneWidget);
    await tester.tap(find.text('Start my walk'));
    await tester.pumpAndSettle();
    expect(find.text('Head toward Oak Street'), findsOneWidget);
  });
}
