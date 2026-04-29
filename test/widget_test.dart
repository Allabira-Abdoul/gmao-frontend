import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final repository = InMemoryCounterRepository();
    final counterState = CounterState(
      getCounterUseCase: GetCounterUseCase(repository),
      incrementCounterUseCase: IncrementCounterUseCase(repository),
    );

    await tester.pumpWidget(MyApp(counterState: counterState));
    await tester.pumpAndSettle();

    expect(find.text('Push the button to start counting!'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Push the button to start counting!'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
