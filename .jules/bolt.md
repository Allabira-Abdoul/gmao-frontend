## 2024-05-24 - [Flutter Scoped Rebuilds]
**Learning:** Rebuilding the entire `Scaffold` or widget tree using `setState` tied to a `ChangeNotifier` triggers unnecessary re-renders of static or unrelated components (like `AppBar`, `FloatingActionButton`, or static texts).
**Action:** Use `ListenableBuilder` (or `AnimatedBuilder` in older Flutter versions) specifically wrapped around the widgets that actually change based on the state. This restricts the rebuild boundary, minimizing computational overhead.
## 2024-04-29 - Flutter state notification optimization
**Learning:** In Flutter's ChangeNotifier, unconditionally calling `notifyListeners()` when mutating state can trigger unnecessary rebuilds of all listening widgets, even if the new value is identical to the old one.
**Action:** Always wrap state mutations and `notifyListeners()` calls with a check that the value has actually changed (`if (_value != newValue)`). This is a simple but highly effective way to prevent wasteful render cycles.
## 2024-05-24 - [Flutter Web Critical Assets Preconnect]
**Learning:** Flutter Web applications (using CanvasKit) lazily fetch required fonts and the engine itself from Google CDNs (`fonts.gstatic.com`, `www.gstatic.com`). By default, the browser doesn't know about these connections until the Dart code requests them, delaying Time to Interactive.
**Action:** Always add `<link rel="preconnect" ...>` tags for critical domains (like gstatic) in `web/index.html` to establish early DNS, TCP, and TLS handshakes.
## 2024-05-24 - [Flutter Localized Rebuilds & Resource Management]
**Learning:** Using `setState()` at the root level of a page to toggle simple UI states (like password visibility) triggers expensive rebuilds of complex descendant widgets such as `BackdropFilter` and `TweenAnimationBuilder`. Additionally, failing to dispose `TextEditingController`s and `ValueNotifier`s creates memory leaks.
**Action:** Use `ValueNotifier` and `ValueListenableBuilder` to isolate rebuilds strictly to the component that needs it. Always override `dispose()` in `StatefulWidget`s to clean up controllers and notifiers.
