import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Wire dependencies the same way main.dart does
    final repository = InMemoryCounterRepository();
    final counterState = CounterState(
      getCounterUseCase: GetCounterUseCase(repository),
      incrementCounterUseCase: IncrementCounterUseCase(repository),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(counterState: counterState));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
