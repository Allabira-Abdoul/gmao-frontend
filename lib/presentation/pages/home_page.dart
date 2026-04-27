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
    widget.counterState.addListener(_onStateChanged);
    widget.counterState.loadCounter();
  }

  @override
  void dispose() {
    widget.counterState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
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
            Text(
              '${widget.counterState.counterValue}',
              style: Theme.of(context).textTheme.headlineMedium,
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
