## 2024-10-24 - Modern Security Headers in vercel.json
**Vulnerability:** Weak security headers (legacy XSS auditor active, missing HSTS preload, missing Permissions-Policy).
**Learning:** Default header setups often use outdated legacy values (like `X-XSS-Protection: 1; mode=block` which is known to cause side-channel vulnerabilities) and lack defense-in-depth features like Permissions-Policy.
**Prevention:** Regularly audit configuration files for web deployments (like `vercel.json` or `nginx.conf`) and update headers to align with current OWASP best practices (X-XSS-Protection: 0, adding HSTS preload, strict Permissions-Policy).
## 2026-04-29 - Flutter Web CSP Requirements
**Vulnerability:** Missing Content Security Policy (CSP) allowing XSS attacks.
**Learning:** Adding a CSP to a Flutter Web app using CanvasKit requires `https://www.gstatic.com` in `script-src` and `connect-src` directives to download `canvaskit.js` and `canvaskit.wasm`. A default strict CSP will break rendering.
**Prevention:** Always ensure `https://www.gstatic.com` is whitelisted when adding CSP headers for Flutter Web.
