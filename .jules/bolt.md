## 2024-05-24 - Flutter LoginPage State Rebuild Optimization
**Learning:** Re-rendering a complex page containing a `BackdropFilter` purely for toggling the visibility of a password input causes heavy performance penalties. Using `setState()` at the page level forces the whole screen to redraw unnecessarily.
**Action:** Always favor `ValueNotifier` and `ValueListenableBuilder` (or `ChangeNotifier`) over `setState()` when localized widget updates are needed within screens carrying expensive layout or visual filters.
