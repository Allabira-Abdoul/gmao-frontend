# 🚀 Deploying the GMAO Flutter Frontend on IIS (Windows Server 2019 Datacenter)

> **No Docker** — This guide deploys the Flutter Web build as static files served directly by IIS with HTTPS.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Build the Flutter Web App](#2-build-the-flutter-web-app)
3. [Install and Configure IIS](#3-install-and-configure-iis)
4. [Deploy the Build Output](#4-deploy-the-build-output)
5. [Configure HTTPS with SSL Certificate](#5-configure-https-with-ssl-certificate)
6. [URL Rewrite for SPA Routing](#6-url-rewrite-for-spa-routing)
7. [Security Headers](#7-security-headers)
8. [MIME Types for Flutter Web](#8-mime-types-for-flutter-web)
9. [Point Frontend to Backend API](#9-point-frontend-to-backend-api)
10. [Firewall & Final Verification](#10-firewall--final-verification)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Prerequisites

| Requirement              | Details                                           |
| ------------------------ | ------------------------------------------------- |
| **OS**                   | Windows Server 2019 Datacenter                    |
| **Flutter SDK**          | Installed on your **build machine** (≥ 3.10)      |
| **IIS**                  | Will be installed via Server Manager               |
| **URL Rewrite Module**   | IIS extension (downloaded from Microsoft)          |
| **SSL Certificate**      | Self-signed (dev) or CA-signed (production)        |
| **Domain / IP**          | The server's FQDN or static IP                    |

> [!NOTE]
> You do **not** need Flutter on the Windows Server itself. You build on your dev machine and copy the output.

---

## 2. Build the Flutter Web App

### 2.1 Update the API Base URLs

Before building, update the backend URLs in the repository files to point to your **Windows Server backend**:

**Files to update:**

- `lib/infrastructure/repositories/http_auth_repository.dart`
- `lib/infrastructure/repositories/http_user_repository.dart`
- `lib/infrastructure/repositories/http_role_repository.dart`

Replace the current AWS EC2 URL:

```dart
// BEFORE
final String baseUrl =
    'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';

// AFTER — use your Windows Server's hostname or IP
final String baseUrl =
    'https://gmao.yourcompany.com/api/user';
```

> [!TIP]
> Consider extracting the base URL into an environment config class so you can switch between environments without editing multiple files.

### 2.2 Update Content-Security-Policy

In `web/index.html`, update the `connect-src` directive to allow your new backend domain:

```html
connect-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com
  https://www.gstatic.com https://gmao.yourcompany.com;
```

### 2.3 Run the Build

On your **development machine** (where Flutter is installed):

```powershell
cd "d:\1. STAGE DE FIN D'ETUDES\1. PROJET\FRONTEND"

flutter clean
flutter pub get
flutter build web --release --base-href "/"
```

The output will be in:

```
build\web\
```

This folder contains all the static files (HTML, JS, CSS, assets) needed for deployment.

### 2.4 Copy to the Server

Copy the entire `build\web\` folder to the Windows Server. For example:

```powershell
# From your dev machine — use your preferred method
# Option A: Shared folder
xcopy /E /I "build\web" "\\SERVER-NAME\C$\inetpub\gmao-frontend"

# Option B: USB / RDP copy-paste
# Just drag and drop the build\web contents into C:\inetpub\gmao-frontend on the server
```

Target path on the server:

```
C:\inetpub\gmao-frontend\
├── assets\
├── icons\
├── flutter_bootstrap.js
├── flutter_service_worker.js
├── index.html
├── main.dart.js
├── manifest.json
└── ...
```

---

## 3. Install and Configure IIS

### 3.1 Install IIS via Server Manager

1. Open **Server Manager** → **Manage** → **Add Roles and Features**
2. Select **Role-based or feature-based installation**
3. Check **Web Server (IIS)**
4. Under **Role Services**, ensure these are checked:
   - ✅ Common HTTP Features → **Static Content**, **Default Document**, **HTTP Errors**
   - ✅ Health and Diagnostics → **HTTP Logging**
   - ✅ Security → **Request Filtering**
   - ✅ Performance → **Static Content Compression**
5. Click **Install** and wait for completion

### 3.2 Install URL Rewrite Module

Download and install from:

```
https://www.iis.net/downloads/microsoft/url-rewrite
```

Or via PowerShell (if Web Platform Installer is available):

```powershell
# Download URL Rewrite 2.1
Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile "$env:TEMP\rewrite.msi"
Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\rewrite.msi /quiet" -Wait
```

> [!IMPORTANT]
> **Restart IIS** after installing URL Rewrite: `iisreset`

### 3.3 Create the IIS Website

Open **IIS Manager** (`inetmgr`):

1. Right-click **Sites** → **Add Website...**
2. Configure:

| Field              | Value                           |
| ------------------ | ------------------------------- |
| Site name          | `GMAO-Frontend`                 |
| Physical path      | `C:\inetpub\gmao-frontend`     |
| Binding Type       | `http` (we'll add HTTPS next)   |
| IP Address         | `All Unassigned`                |
| Port               | `80`                            |
| Host name          | `gmao.yourcompany.com` (or blank for IP-only) |

3. Click **OK**

---

## 4. Deploy the Build Output

If you haven't already copied the files (Step 2.4), do it now. Ensure the IIS website physical path points to the folder containing `index.html` at its root.

### 4.1 Set Folder Permissions

```powershell
# Grant IIS read access
icacls "C:\inetpub\gmao-frontend" /grant "IIS_IUSRS:(OI)(CI)R" /T
icacls "C:\inetpub\gmao-frontend" /grant "IUSR:(OI)(CI)R" /T
```

### 4.2 Set Default Document

In IIS Manager:

1. Select your **GMAO-Frontend** site
2. Double-click **Default Document**
3. Ensure `index.html` is in the list (add it if not)

---

## 5. Configure HTTPS with SSL Certificate

### Option A: Self-Signed Certificate (Development / Testing)

```powershell
# Generate a self-signed certificate
New-SelfSignedCertificate `
    -DnsName "gmao.yourcompany.com" `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -FriendlyName "GMAO Frontend SSL" `
    -NotAfter (Get-Date).AddYears(3)
```

### Option B: CA-Signed Certificate (Production)

1. Generate a Certificate Signing Request (CSR) in IIS Manager:
   - Select your server in IIS Manager
   - Double-click **Server Certificates**
   - Click **Create Certificate Request...** in the Actions pane
   - Fill in your organization details and specify a filename for the CSR
2. Submit the CSR to your Certificate Authority (e.g., DigiCert, Let's Encrypt, your company's internal CA)
3. Once you receive the `.cer` file, go back to **Server Certificates** → **Complete Certificate Request...**

### 5.1 Bind HTTPS to the Site

1. In IIS Manager, select **GMAO-Frontend** site
2. Click **Bindings...** in the Actions pane
3. Click **Add...**

| Field           | Value                          |
| --------------- | ------------------------------ |
| Type            | `https`                        |
| IP Address      | `All Unassigned`               |
| Port            | `443`                          |
| Host name       | `gmao.yourcompany.com`         |
| SSL Certificate | Select your certificate        |

4. ✅ Check **Require Server Name Indication** if hosting multiple HTTPS sites
5. Click **OK**

### 5.2 Force HTTPS Redirect (HTTP → HTTPS)

Create or edit `C:\inetpub\gmao-frontend\web.config`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <!-- Force HTTPS -->
        <rule name="HTTP to HTTPS" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

---

## 6. URL Rewrite for SPA Routing

Flutter Web uses client-side routing. All routes must fall back to `index.html` — identical to the `rewrites` rule in your existing `vercel.json`.

Update `C:\inetpub\gmao-frontend\web.config` to include the SPA fallback rule:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <!-- 1. Force HTTPS -->
        <rule name="HTTP to HTTPS" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
        </rule>

        <!-- 2. SPA Fallback — serve index.html for all non-file routes -->
        <rule name="SPA Fallback" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

> [!IMPORTANT]
> Without this rule, refreshing the browser on any route other than `/` will return a **404 error**.

---

## 7. Security Headers

Replicate the security headers from your `vercel.json`. Add these to `web.config` inside `<system.webServer>`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>

    <!-- Security Headers -->
    <httpProtocol>
      <customHeaders>
        <remove name="X-Powered-By" />
        <add name="X-Content-Type-Options" value="nosniff" />
        <add name="X-Frame-Options" value="DENY" />
        <add name="X-XSS-Protection" value="0" />
        <add name="Strict-Transport-Security" value="max-age=31536000; includeSubDomains; preload" />
        <add name="Referrer-Policy" value="strict-origin-when-cross-origin" />
        <add name="Permissions-Policy" value="camera=(), microphone=(), geolocation=(), browsing-topics=()" />
      </customHeaders>
    </httpProtocol>

    <!-- URL Rewrite Rules -->
    <rewrite>
      <rules>
        <rule name="HTTP to HTTPS" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
        </rule>
        <rule name="SPA Fallback" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>

  </system.webServer>
</configuration>
```

---

## 8. MIME Types for Flutter Web

Flutter Web uses `.wasm` files and other modern formats. IIS may not serve them by default. Add these MIME types in `web.config` inside `<system.webServer>`:

```xml
<staticContent>
  <remove fileExtension=".wasm" />
  <mimeMap fileExtension=".wasm" mimeType="application/wasm" />
  <remove fileExtension=".json" />
  <mimeMap fileExtension=".json" mimeType="application/json" />
  <remove fileExtension=".woff" />
  <mimeMap fileExtension=".woff" mimeType="font/woff" />
  <remove fileExtension=".woff2" />
  <mimeMap fileExtension=".woff2" mimeType="font/woff2" />
</staticContent>
```

---

## 9. Point Frontend to Backend API

Your Go microservices (behind IIS reverse proxy) are on the **same server**. Update the Dart base URLs before building:

| Repository File           | Base URL Value                                |
| ------------------------- | --------------------------------------------- |
| `http_auth_repository.dart` | `https://gmao.yourcompany.com/api/authentication` |
| `http_user_repository.dart`  | `https://gmao.yourcompany.com/api/user`           |
| `http_role_repository.dart`  | `https://gmao.yourcompany.com/api/user`           |

> [!TIP]
> If frontend and backend are on the **same IIS server** and same domain, CORS issues are eliminated because the origin matches.

---

## 10. Firewall & Final Verification

### 10.1 Open Firewall Ports

```powershell
# Allow HTTPS (443)
New-NetFirewallRule -DisplayName "IIS HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow

# Allow HTTP (80) — for the redirect only
New-NetFirewallRule -DisplayName "IIS HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
```

### 10.2 Restart IIS

```powershell
iisreset
```

### 10.3 Verify Deployment

| Test                                   | Expected Result                          |
| -------------------------------------- | ---------------------------------------- |
| `http://gmao.yourcompany.com`          | Redirects to `https://...`               |
| `https://gmao.yourcompany.com`         | Flutter app loads                        |
| `https://gmao.yourcompany.com/login`   | Flutter app loads (SPA routing works)    |
| Refresh on any route                   | No 404 — app reloads correctly           |
| Check response headers (DevTools → Network) | Security headers present            |
| Login flow                             | API calls succeed to backend             |

---

## 11. Troubleshooting

### Blank page / app doesn't load

- Check that `flutter_bootstrap.js` and `main.dart.js` are in the site root
- Ensure `--base-href "/"` was used during build
- Open browser DevTools → Console for errors

### 404 on refresh

- URL Rewrite Module is not installed → install it and `iisreset`
- The SPA fallback rule is missing from `web.config`

### WASM errors in console

- Missing MIME type — ensure `.wasm → application/wasm` is configured

### HTTPS certificate warning

- Self-signed cert: expected in browser, add exception
- CA-signed cert: ensure the full certificate chain is installed

### CORS errors when calling API

- If frontend and backend share the same origin (same domain + port), CORS is not needed
- If on different domains/ports, configure CORS headers in your Go backend or IIS ARR rules

### 502 / API calls fail

- Verify the Go backend services are running
- Check IIS ARR reverse proxy rules for the backend (see your backend deployment guide)

---

## Complete `web.config`

Here is the final, consolidated `web.config` to place at `C:\inetpub\gmao-frontend\web.config`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>

    <!-- Remove server identity header -->
    <httpProtocol>
      <customHeaders>
        <remove name="X-Powered-By" />
        <add name="X-Content-Type-Options" value="nosniff" />
        <add name="X-Frame-Options" value="DENY" />
        <add name="X-XSS-Protection" value="0" />
        <add name="Strict-Transport-Security"
             value="max-age=31536000; includeSubDomains; preload" />
        <add name="Referrer-Policy"
             value="strict-origin-when-cross-origin" />
        <add name="Permissions-Policy"
             value="camera=(), microphone=(), geolocation=(), browsing-topics=()" />
      </customHeaders>
    </httpProtocol>

    <!-- MIME types for Flutter Web -->
    <staticContent>
      <remove fileExtension=".wasm" />
      <mimeMap fileExtension=".wasm" mimeType="application/wasm" />
      <remove fileExtension=".json" />
      <mimeMap fileExtension=".json" mimeType="application/json" />
      <remove fileExtension=".woff" />
      <mimeMap fileExtension=".woff" mimeType="font/woff" />
      <remove fileExtension=".woff2" />
      <mimeMap fileExtension=".woff2" mimeType="font/woff2" />
    </staticContent>

    <!-- URL Rewrite -->
    <rewrite>
      <rules>
        <!-- Force HTTPS -->
        <rule name="HTTP to HTTPS" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true" />
          </conditions>
          <action type="Redirect"
                  url="https://{HTTP_HOST}/{R:1}"
                  redirectType="Permanent" />
        </rule>
        <!-- SPA Fallback -->
        <rule name="SPA Fallback" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>

    <!-- Enable compression -->
    <urlCompression doStaticCompression="true" doDynamicCompression="false" />

    <!-- Default document -->
    <defaultDocument>
      <files>
        <clear />
        <add value="index.html" />
      </files>
    </defaultDocument>

  </system.webServer>
</configuration>
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│              Windows Server 2019 Datacenter         │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │                   IIS 10                      │  │
│  │                                               │  │
│  │  ┌─────────────────────┐  ┌────────────────┐  │  │
│  │  │  GMAO-Frontend      │  │  GMAO-Backend  │  │  │
│  │  │  (Static files)     │  │  (ARR Reverse  │  │  │
│  │  │                     │  │   Proxy)       │  │  │
│  │  │  :443 HTTPS         │  │  /api/*        │  │  │
│  │  │  C:\inetpub\        │  │  → localhost:  │  │  │
│  │  │   gmao-frontend\    │  │    8081-8085   │  │  │
│  │  └─────────────────────┘  └────────────────┘  │  │
│  │                                               │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────┐       │
│  │  Go Microservices (running as services)  │       │
│  │  • auth-service     :8081               │       │
│  │  • user-service     :8082               │       │
│  │  • equipment-service :8083              │       │
│  │  • workorder-service :8084              │       │
│  └──────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘
```

> **Client Browser** → `https://gmao.yourcompany.com` → **IIS** serves Flutter static files  
> **Flutter App** → `https://gmao.yourcompany.com/api/*` → **IIS ARR** proxies to Go services
