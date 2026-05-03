import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/pages/home_page.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final counterRepository = InMemoryCounterRepository();
    final getCounterUseCase = GetCounterUseCase(counterRepository);
    final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);

    final counterState = CounterState(
      getCounterUseCase: getCounterUseCase,
      incrementCounterUseCase: incrementCounterUseCase,
    );

    await tester.pumpWidget(
      MaterialApp(home: HomePage(counterState: counterState)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Push the button to start counting!'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Push the button to start counting!'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
