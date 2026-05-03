## 2024-10-24 - Modern Security Headers in vercel.json
**Vulnerability:** Weak security headers (legacy XSS auditor active, missing HSTS preload, missing Permissions-Policy).
**Learning:** Default header setups often use outdated legacy values (like `X-XSS-Protection: 1; mode=block` which is known to cause side-channel vulnerabilities) and lack defense-in-depth features like Permissions-Policy.
**Prevention:** Regularly audit configuration files for web deployments (like `vercel.json` or `nginx.conf`) and update headers to align with current OWASP best practices (X-XSS-Protection: 0, adding HSTS preload, strict Permissions-Policy).
## 2026-04-29 - Flutter Web CSP Requirements
**Vulnerability:** Missing Content Security Policy (CSP) allowing XSS attacks.
**Learning:** Adding a CSP to a Flutter Web app using CanvasKit requires `https://www.gstatic.com` in `script-src` and `connect-src` directives to download `canvaskit.js` and `canvaskit.wasm`. A default strict CSP will break rendering.
**Prevention:** Always ensure `https://www.gstatic.com` is whitelisted when adding CSP headers for Flutter Web.
## 2024-05-24 - Android Backup Data Leakage Prevention
**Vulnerability:** Android application backup enabled by default.
**Learning:** Default Android configurations allow local app data to be backed up (e.g. via `adb backup`). This can lead to local data leakage of sensitive user information, settings, or database content to an attacker with physical access or malicious apps exploiting backup configurations.
**Prevention:** Explicitly set `android:allowBackup="false"` and `android:fullBackupContent="false"` in the `<application>` tag of `AndroidManifest.xml` to prevent unintentional exposure of app data.
## $(date +%Y-%m-%d) - Unprotected Client-Side Routes in Flutter
**Vulnerability:** Missing authorization checks on sensitive application routes.
**Learning:** Routes defined directly in the `MaterialApp` routes table without a surrounding guard allow any user, authenticated or not, to bypass expected flows and access sensitive screens by deep-linking or route manipulation.
**Prevention:** Always wrap sensitive routes with a component like `AuthGuard` that explicitly verifies both the authentication state and required role, redirecting unauthorized access appropriately before the widget renders.
