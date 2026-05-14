# 🚀 Codemagic Build Setup — Janki Agro Tourism

---

## STEP 1 — Push Code to GitHub

1. Create a new repository on https://github.com (e.g. `janki-agro-tourism`)
2. Open terminal and run:

```bash
cd janki_agro_tourism
git init
git add .
git commit -m "Initial commit - Janki Agro Tourism Flutter app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/janki-agro-tourism.git
git push -u origin main
```

---

## STEP 2 — Connect Codemagic

1. Go to → https://codemagic.io
2. Sign up / Log in (free with GitHub)
3. Click **"Add application"**
4. Select **GitHub** → Authorize → choose your repo `janki-agro-tourism`
5. Select **Flutter App** as the project type
6. Click **"Finish: Add application"**

---

## STEP 3 — Select YAML Configuration

1. In your app on Codemagic, go to **"Workflow Editor"**
2. Switch to **"codemagic.yaml"** tab (top right)
3. Codemagic will auto-detect the `codemagic.yaml` from your repo root
4. You will see **4 workflows** listed:
   - `android-debug-apk` ← **Start with this one (no signing needed)**
   - `android-release-apk`
   - `android-release-aab`
   - `ios-release`

---

## STEP 4 — Build Debug APK (Quickest — No Setup Needed)

1. Select workflow: **`android-debug-apk`**
2. Click **"Start new build"**
3. Wait ~10–15 minutes
4. Download the APK from the **Artifacts** section
5. Install on your Android phone and test ✅

---

## STEP 5 — Build Release APK (Signed — For Sharing/Distribution)

### 5a. Generate a Keystore (run once on your PC)

```bash
keytool -genkey -v \
  -keystore janki-release.keystore \
  -alias janki_key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Fill in the prompts (name, organization, etc.). Remember:
- `keystore password`
- `key alias` → `janki_key`
- `key password`

### 5b. Upload Keystore to Codemagic

1. Go to Codemagic → **Team Settings** → **Code Signing identities**
2. Under **Android keystores** → click **"Add keystore"**
3. Upload `janki-release.keystore`
4. Fill in:
   - **Reference name:** `janki_keystore` ← must match codemagic.yaml exactly
   - **Keystore password:** (your password)
   - **Key alias:** `janki_key`
   - **Key password:** (your password)
5. Click **Save**

### 5c. Run Release Build

1. Select workflow: **`android-release-apk`**
2. Click **"Start new build"**
3. Download signed APK from Artifacts ✅

---

## STEP 6 — Email Notification Setup

In `codemagic.yaml`, update the email under each workflow:

```yaml
publishing:
  email:
    recipients:
      - yourname@gmail.com    # ← Put your real email here
```

Commit and push the change:
```bash
git add codemagic.yaml
git commit -m "Add email notification"
git push
```

---

## STEP 7 — iOS Build (Optional — Requires Apple Developer Account ₹8,499/year)

Only needed if you want to distribute on iPhone / App Store.

1. Join Apple Developer Program → https://developer.apple.com
2. In Codemagic → **Team Settings** → **Code Signing** → Add iOS certificate + provisioning profile
3. Select workflow: **`ios-release`**
4. Build and download IPA

---

## File Structure After Setup

```
janki_agro_tourism/
├── codemagic.yaml              ← Build config (all 4 workflows)
├── pubspec.yaml                ← Flutter dependencies
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── services/
│   ├── utils/
│   ├── widgets/
│   └── screens/
│       ├── admin/
│       └── manager/
├── android/
│   ├── app/
│   │   ├── build.gradle        ← App-level build config
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/janki/agrotourism/MainActivity.kt
│   │       └── res/
│   ├── build.gradle            ← Root build config
│   ├── gradle.properties
│   ├── settings.gradle
│   └── gradle/wrapper/
│       └── gradle-wrapper.properties
└── ios/
    ├── Podfile
    ├── Runner/
    │   ├── AppDelegate.swift
    │   ├── Info.plist
    │   └── Assets.xcassets/
    └── Runner.xcodeproj/
        └── project.pbxproj
```

---

## Workflow Summary

| Workflow | Output | Signing | Use Case |
|---|---|---|---|
| `android-debug-apk` | `.apk` | None | Quick testing |
| `android-release-apk` | `.apk` | Keystore | Share with users |
| `android-release-aab` | `.aab` | Keystore | Google Play Store |
| `ios-release` | `.ipa` | Apple Cert | iPhone / App Store |

---

## Troubleshooting

**Build fails with "flutter.sdk not found"**
→ Codemagic sets this automatically. Make sure `flutter: stable` is in codemagic.yaml ✅

**"Keystore not found"**
→ Confirm the reference name `janki_keystore` matches exactly in codemagic.yaml and Codemagic UI

**"minSdkVersion" error**
→ Already set to 21 in `android/app/build.gradle` ✅

**Gradle build slow**
→ Cache is configured in codemagic.yaml (`~/.gradle/caches`) — second build will be faster

**App crashes on launch**
→ Test debug APK first. Most common cause: missing `flutter pub get`
   (already in build scripts ✅)

---

## Default App Login

After installing the APK:
- **Admin login:** `admin` / `admin123`
- Add managers from Admin Dashboard → Managers
