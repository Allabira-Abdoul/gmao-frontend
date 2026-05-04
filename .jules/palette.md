## 2024-05-01 - Tooltips for icon-only buttons
**Learning:** Found multiple icon-only `IconButton`s (password visibility toggle, dashboard logout buttons) lacking tooltips. This is a common accessibility issue for screen readers and missing context for mouse hover users.
**Action:** Always add `tooltip` properties to `IconButton`s containing only an icon, ensuring the text is correctly localized for the user interface context (e.g., 'Déconnexion' instead of 'Logout' for a French UI).
