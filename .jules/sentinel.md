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
## 2026-05-01 - Missing Client-Side Route Authentication
**Vulnerability:** Missing authorization checks on sensitive Flutter routes.
**Learning:** In a Single Page Application (SPA) architecture like Flutter Web or desktop/mobile, defining routes in `MaterialApp` without wrapping them in an authentication guard allows unauthenticated users to access sensitive pages (like admin dashboards) by directly navigating to the route or if the initial routing logic is bypassed. Even if the API is secure, this can leak UI elements or cached data.
**Prevention:** Always protect sensitive application routes using a route guard or wrapper widget (e.g., `_protectedRoute`) that verifies both the user's authentication status and role permissions before rendering the route's widget.

## 2026-05-01 - Insecure Token Storage
**Vulnerability:** JWT tokens (access and refresh) were stored in plaintext using `SharedPreferences`.
**Learning:** `SharedPreferences` saves data in plaintext XML on Android and `NSUserDefaults` on iOS, making sensitive tokens easily accessible to attackers who compromise the device or application space. This can lead to account takeover.
**Prevention:** Always use secure storage solutions like `flutter_secure_storage` (which uses Keystore on Android and Keychain on iOS) for storing authentication tokens or other sensitive secrets.
