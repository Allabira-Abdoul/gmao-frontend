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
            // ⚡ Bolt Optimization: Use ListenableBuilder to prevent full page re-renders.
            // This scopes rebuilds strictly to the conditional UI when the counter changes.
            ListenableBuilder(
              listenable: widget.counterState,
              builder: (context, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.counterState.counterValue == 0
                      ? const Column(
                          key: ValueKey('empty_state'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.ads_click,
                              size: 64,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Push the button to start counting!',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('active_state'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'You have pushed the button this many times:',
                            ),
                            Text(
                              '${widget.counterState.counterValue}',
                              key: const ValueKey('counter_text'),
                              style: Theme.of(context).textTheme.headlineMedium,
                              semanticsLabel:
                                  '${widget.counterState.counterValue} presses',
                            ),
                          ],
                        ),
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
