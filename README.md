# My Study Planner

A Flutter app to track study goals — subjects, hours planned, and completion status.

This guide is written for beginners. It walks you through running the app as an **Android app** on **macOS** or **Windows**.

---

## What you need before starting

| Tool | Why you need it |
|------|-----------------|
| [Git](https://git-scm.com/downloads) | Clone the repository |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | Build and run the app |
| [Android Studio](https://developer.android.com/studio) | Android SDK, emulator, and build tools |
| A code editor (VS Code or Android Studio) | Edit Dart code |

**Recommended Flutter version:** 3.44+ (Dart 3.12+)

---

## 1. Clone the project

```bash
git clone https://github.com/Yoctan241/My-Study-Planner-G6.git
cd My-Study-Planner-G6
flutter pub get
```

`flutter pub get` downloads the project's Dart packages. Run it once after cloning, and again whenever `pubspec.yaml` changes.

---

## 2. Set up your machine

Pick the section that matches your operating system.

### macOS — Android setup

#### Step 1: Install Flutter

1. Download Flutter for macOS from the [official install guide](https://docs.flutter.dev/get-started/install/macos).
2. Extract the archive (for example to `~/development/flutter`).
3. Add Flutter to your PATH. In `~/.zshrc` (or `~/.bash_profile`):

   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```

4. Restart your terminal, then verify:

   ```bash
   flutter --version
   ```

#### Step 2: Install Android Studio

1. Download and install [Android Studio](https://developer.android.com/studio).
2. Open Android Studio → **Settings** (or **Preferences** on Mac) → **Languages & Frameworks** → **Android SDK**.
3. On the **SDK Platforms** tab, install at least one recent Android version (e.g. Android 14 or 15).
4. On the **SDK Tools** tab, make sure these are checked and installed:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools

#### Step 3: Accept Android licenses

```bash
flutter doctor --android-licenses
```

Type `y` to accept each license prompt.

#### Step 4: Create an Android emulator (virtual phone)

1. Open Android Studio → **More Actions** → **Virtual Device Manager** (or **Tools → Device Manager**).
2. Click **Create Device**.
3. Pick a phone (e.g. Pixel 7) → **Next**.
4. Download a system image (e.g. API 34) → **Next** → **Finish**.
5. Press the **Play** button to start the emulator.

#### Step 5: Verify everything

```bash
flutter doctor
```

You want a checkmark (✓) next to **Flutter** and **Android toolchain**. Fix any issues `flutter doctor` reports before continuing.

---

### Windows — Android setup

#### Step 1: Install Flutter

1. Download Flutter for Windows from the [official install guide](https://docs.flutter.dev/get-started/install/windows).
2. Extract the zip (for example to `C:\src\flutter` — avoid paths with spaces or special characters).
3. Add Flutter to your PATH:
   - Open **Start** → search **"Environment Variables"** → **Edit the system environment variables**.
   - Click **Environment Variables**.
   - Under **User variables**, select **Path** → **Edit** → **New**.
   - Add: `C:\src\flutter\bin` (use your actual Flutter path).
   - Click **OK** on all dialogs.
4. Open a **new** Command Prompt or PowerShell window, then verify:

   ```cmd
   flutter --version
   ```

#### Step 2: Install Android Studio

1. Download and install [Android Studio](https://developer.android.com/studio).
2. Open Android Studio → **Settings** → **Languages & Frameworks** → **Android SDK**.
3. On the **SDK Platforms** tab, install at least one recent Android version.
4. On the **SDK Tools** tab, install:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools

#### Step 3: Set the Android SDK environment variable (recommended)

1. In Android Studio, note your SDK path (usually `C:\Users\<YourName>\AppData\Local\Android\Sdk`).
2. Open **Environment Variables** (same as Step 1 above).
3. Under **User variables**, click **New**:
   - Variable name: `ANDROID_HOME`
   - Variable value: your SDK path (e.g. `C:\Users\YourName\AppData\Local\Android\Sdk`)
4. Edit **Path** and add:
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\cmdline-tools\latest\bin`
5. Restart your terminal.

#### Step 4: Accept Android licenses

```cmd
flutter doctor --android-licenses
```

Type `y` for each prompt.

#### Step 5: Create an Android emulator

1. Open Android Studio → **More Actions** → **Virtual Device Manager**.
2. Click **Create Device** → choose a phone → **Next**.
3. Download a system image → **Next** → **Finish**.
4. Click the **Play** button to launch the emulator.

> **Windows note:** Enable **Virtualization** in your BIOS/UEFI if the emulator fails to start. On Windows 11, also turn on **Windows Hypervisor Platform** and **Virtual Machine Platform** under **Settings → System → Optional features**.

#### Step 6: Verify everything

```cmd
flutter doctor
```

Fix any reported issues before running the app.

---

## 3. Run the app on Android

Make sure an emulator is running, or a physical phone is connected (see below).

From the project folder:

```bash
flutter devices
```

You should see an Android device listed. Then run:

```bash
flutter run
```

Flutter builds the app and installs it on the device. The first build can take several minutes.

### Useful commands while the app is running

| Key | Action |
|-----|--------|
| `r` | Hot reload — apply code changes quickly |
| `R` | Hot restart — full app restart |
| `q` | Quit |

### Run on a specific device

If multiple devices are connected:

```bash
flutter run -d <device-id>
```

Use the device ID shown by `flutter devices` (e.g. `emulator-5554`).

---

## 4. Run on a physical Android phone (optional)

1. On your phone: **Settings → About phone** → tap **Build number** 7 times to enable Developer options.
2. Go to **Settings → Developer options** → enable **USB debugging**.
3. Connect the phone via USB.
4. On the phone, tap **Allow** when asked to trust the computer.
5. Run:

   ```bash
   flutter devices
   flutter run
   ```

On Windows, you may need to [install USB drivers](https://developer.android.com/studio/run/oem-usb) for your phone brand.

---

## 5. What the app does (current version)

- View a list of study goals (subject + hours)
- See summary stats: total goals, hours, and completed count
- Mark goals as done or not done
- Delete goals
- Add new goals — the **+** button is not wired up yet (good first task for contributors)

All data is stored in memory for now — closing the app resets the list.

---

## 6. Project structure (the basics)

```
lib/
  main.dart          # App entry point and UI (for now, everything is here)
test/
  widget_test.dart   # Automated UI tests
android/             # Android-specific config (you rarely edit this early on)
pubspec.yaml         # Project name, dependencies, and Flutter settings
```

As the project grows, code will likely move into folders like `lib/models/`, `lib/screens/`, and `lib/widgets/`.

---

## 7. Common problems and fixes

### `flutter` is not recognized

Flutter is not on your PATH. Re-check the PATH steps in section 2 and open a **new** terminal window.

### No devices found

- Start the Android emulator from Android Studio (**Device Manager → Play**).
- Or connect a phone with USB debugging enabled.
- Run `flutter devices` to confirm Flutter sees the device.

### Android licenses not accepted

```bash
flutter doctor --android-licenses
```

### Build fails with SDK or Gradle errors

```bash
flutter clean
flutter pub get
flutter run
```

If it still fails, open the project in Android Studio once and let it download any missing SDK components.

### Emulator is very slow

- In the emulator settings, reduce RAM if your machine is low on memory.
- Use a physical phone via USB — often faster than an emulator.
- On Windows, ensure virtualization is enabled in BIOS.

### First build takes a long time

This is normal. Gradle downloads dependencies on the first run. Later builds are much faster.

---

## 8. Contributing (team workflow)

1. Pull the latest code:

   ```bash
   git pull origin main
   ```

2. Create a branch for your work:

   ```bash
   git checkout -b your-name/feature-description
   ```

3. Make changes, then verify:

   ```bash
   flutter analyze
   flutter run
   ```

4. Push and open a Pull Request on GitHub.

Coordinate with your teammates so two people don't work on the same feature.

---

## 9. Learn more

- [Flutter documentation](https://docs.flutter.dev/)
- [Dart language tour](https://dart.dev/guides/language/language-tour)
- [Write your first Flutter app (codelab)](https://docs.flutter.dev/get-started/codelab)
- [macOS Android setup (official)](https://docs.flutter.dev/platform-integration/android/setup)
- [Windows Android setup (official)](https://docs.flutter.dev/platform-integration/android/setup)

---

## Repository

**GitHub:** [Yoctan241/My-Study-Planner-G6](https://github.com/Yoctan241/My-Study-Planner-G6)
