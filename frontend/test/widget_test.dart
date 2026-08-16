import 'package:flutter_test/flutter_test.dart';
import 'package:flurt_frontend/main.dart';

void main() {
  testWidgets('FlurtApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FlurtApp());
    expect(find.byType(FlurtApp), findsOneWidget);
  });
}
