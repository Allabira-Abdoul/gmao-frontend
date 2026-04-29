## 2024-04-27 - Added Empty State to Counter App
**Learning:** Found an opportunity to improve UX by providing an empty state for the counter when it is 0, guiding users instead of just showing "0". Also added semantics labels for accessibility.
**Action:** Always look for opportunities to replace generic numeric empty states with actionable, helpful empty states containing icons and text, and ensure semantic labels are applied for screen readers.

## 2026-04-28 - Remove redundant semantic label from empty state decorative icon
**Learning:** Screen readers announce text in `semanticLabel` on `Icon` widgets even if the icon is purely decorative. If the icon accompanies clear descriptive text right beneath it, having a redundant semantic label like "Empty state icon" just creates noise for screen reader users.
**Action:** When an icon is purely visual/decorative and the adjacent text clearly communicates the state, leave `semanticLabel` null so it is ignored by screen readers, creating a cleaner a11y experience.
## 2026-04-29 - Live Region for Dynamic Text
**Learning:** When text changes dynamically in Flutter, screen readers won't automatically announce it. Providing a semantic label to the text doesn't help with dynamic announcements.
**Action:** Wrap dynamically updating text widgets (like counters or timers) in `Semantics(liveRegion: true)` to ensure screen readers announce the changes automatically.
