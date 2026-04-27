/// Domain entity representing a Counter.
///
/// This is a pure business object with no framework dependencies.
class Counter {
  final int value;

  const Counter({this.value = 0});

  Counter increment() => Counter(value: value + 1);

  Counter decrement() => Counter(value: value > 0 ? value - 1 : 0);

  Counter reset() => const Counter();
}
