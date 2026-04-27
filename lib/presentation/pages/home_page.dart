import 'package:flutter/material.dart';
import 'package:frontend/presentation/state/counter_state.dart';

/// Home page widget.
///
/// Receives its [CounterState] via constructor injection,
/// keeping it decoupled from the dependency wiring in main.dart.
class HomePage extends StatefulWidget {
  final CounterState counterState;

  const HomePage({super.key, required this.counterState});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.counterState.loadCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hexagonal Architecture Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            // ⚡ Bolt Optimization: Use ListenableBuilder to prevent full page re-renders.
            // This scopes rebuilds strictly to the Text widget when counter changes.
            ListenableBuilder(
              listenable: widget.counterState,
              builder: (context, _) {
                return Text(
                  '${widget.counterState.counterValue}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.counterState.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
