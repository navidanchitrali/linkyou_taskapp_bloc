import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/main.dart';
 
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('TaskFlow'), findsOneWidget);
  });
}