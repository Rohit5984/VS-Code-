```Prompt
Follow the phases IN ORDER. Do NOT build any installer/APK until Phase 5 (Verification Gate) passes 100%. Report results after every phase before moving to the next. If something cannot be fixed, STOP and explain why — do not silently skip it.

0. MISSION

This app must feel like it belongs next to Revolut, Linear, Spotify, Apple Health, Notion. Specifically:

Zero lag — every tap, transition, and screen load must feel instant (<100ms response, <300ms screen transitions).
Zero crashes, zero silent failures — every action either works or shows a clear, graceful error/retry state. Never a frozen UI, never a blank screen, never a generic crash.
Every interactive element must actually work — buttons, toggles, switches, sliders, tabs, forms, navigation — no dead taps, no fake/non-functional UI.
Visually premium — glassmorphism + prism gradient design, perfect alignment, perfect spacing, modern fonts, harmonious colors. Nothing should look like a default Flutter template.
No user should ever feel "something is off." If you (the AI) notice any rough edge — inconsistent spacing, a button that's slightly misaligned, a color that clashes, a slow screen — fix it even if not explicitly listed below.

1. ENVIRONMENT (fixed — do not ask, do not guess)

Flutter SDK     : C:\src\flutter\
Android SDK     : C:\android-sdk\
cmdline-tools   : C:\cmdline-tools\
JDK             : C:\jdk17\
Inno Setup 6    : C:\Program Files (x86)\Inno Setup 6\

Verify and fix if wrong:

flutter doctor -v passes with no errors for the active target platform.
android/local.properties → sdk.dir=C:\\android-sdk\\
JAVA_HOME=C:\jdk17\, ANDROID_HOME/ANDROID_SDK_ROOT=C:\android-sdk\
cmdline-tools correctly linked under the Android SDK's cmdline-tools folder, accepted licenses (sdkmanager --licenses).
Inno Setup 6 executable exists at the given path and is invoked correctly by the Windows build script (ISCC.exe "installer.iss").

2. SINGLE-SOURCE PLATFORM SWITCH (CRITICAL — must be perfect)

Create ONE config file as the single source of truth, e.g.:

yaml# build_config.yaml
target_platform: android  # <-- THE ONLY LINE THAT CHANGES. Values: "windows"

Rules:

Only one of the two platforms is ever active at a time. Whatever this value is, that is the ONLY platform that gets built, packaged, and installed when the build script runs.
Every script, Dart conditional, and Python packaging step must read this single value — never duplicate platform logic elsewhere. Refactor any scattered Platform.isWindows / Platform.isAndroid checks so they all reference one central AppTarget helper that loads this config.
Provide exactly two entry-point scripts:

build_windows.bat — runs ONLY when target_platform: windows. Sequence: flutter clean → flutter pub get → flutter build windows --release → package Python backend (PyInstaller or equivalent, onefile, no console window unless debugging) → copy backend exe + assets into the Flutter Windows release output → run Inno Setup (ISCC.exe) against an .iss script that bundles everything into one signed-ready installer .exe → output to /dist/windows/AppName-Setup.exe.
build_android.bat — runs ONLY when target_platform: android. Sequence: flutter clean → flutter pub get → flutter build apk --release (and appbundle if needed) → ensure backend is reachable appropriately for mobile (bundled native service, embedded server, or remote API client — confirm which mode is configured and that it's correctly wired) → output to /dist/android/app-release.apk.

If the script for the inactive platform is run by mistake, it must immediately print a clear message and exit — never attempt a partial/wrong build.
The installer/APK must NEVER be built before Phase 5's verification gate passes. Both scripts must call a verify_before_build step first that fails the build if any check from Phase 5 hasn't passed.

3. FULL CODEBASE RE-VERIFICATION (file by file — do not sample, read everything)

3.1 Structure & hygiene

Map every folder/file in Flutter (lib/) and Python backend.
Flag dead code, duplicate widgets, orphaned screens, unused imports, unused packages (pubspec.yaml, requirements.txt), unused assets/fonts/images.
Confirm clean architecture: lib/screens/, lib/widgets/, lib/core/theme/, lib/core/config/, lib/services/, lib/models/.

3.2 Navigation & flow integrity

Trace every route from splash → onboarding/welcome → auth (if any) → home → every feature screen → settings → back to home.
No dead-end screens, no missing back button/gesture, no duplicate route names, no broken deep links.
Confirm state management approach (Provider/Bloc/Riverpod/GetX) is used consistently — not mixed ad-hoc per screen.

3.3 Every interactive element must be verified individually

Build a checklist of every button, toggle, switch, slider, tab, chip, form field, and gesture in the app. For each one confirm:

It is wired to a real function (not a stub/onTap: () {}).
The function executes successfully, shows loading state while working, and shows success/error feedback.
Toggles/switches persist their state correctly (in-memory and, where expected, across app restarts).
Disabled/loading/error states are visually distinct, not just functionally different.

3.4 Backend integration

Every API/function call from Flutter to the Python backend must have: timeout handling, retry or clear error message, loading indicator, and graceful fallback (no infinite spinners, no frozen screens).
Confirm backend endpoints used by the app actually return the expected data shape; fix mismatches.

3.5 Error & crash audit

Search for unhandled try/catch gaps, null-safety violations, async race conditions, unguarded late variables, unbounded recursive calls.
Force-test edge cases: no internet, empty data states, slow backend response, rapid repeated taps, rotating screen/resizing window.
Fix every one found. None may remain "known issues."

4. PERFORMANCE BUDGET (must be measured, not assumed)

Cold start to first interactive frame: under 2 seconds on a mid-range device/PC.
Screen-to-screen navigation: under 300ms, no visible jank/frame drops (target 60fps, no dropped frames in flutter run --profile).
Tap-to-feedback latency: under 100ms for any button/toggle.
No unnecessary full-tree rebuilds: use const constructors wherever possible, scope setState/state listeners narrowly, use ListView.builder/Sliver for lists instead of building everything up front, wrap expensive static visuals in RepaintBoundary.
Images/assets compressed and correctly sized for their display dimensions (no 4K image rendered in a 40px icon).
Backend calls must not block the UI thread — confirm all network/IO is async and shows non-blocking loading states.
Run flutter build apk --analyze-size / equivalent for Windows and report final bundle size; flag and trim anything bloated.

5. UI/UX REDESIGN — GLASSMORPHISM + PRISM GRADIENT (premium, modern, benchmarked)

Benchmark visually against Revolut, Linear, Apple Health, Spotify, Notion before making changes. Then apply, as ONE shared design system (never per-screen one-offs):

5.1 Theme source of truth

AppColors: primary, secondary, accent, prism gradient stops (e.g. indigo → violet → magenta, or teal → blue → purple), success/warning/error, text-on-glass colors meeting WCAG AA contrast in both light & dark mode.
AppTypography: one modern font pairing (e.g. Sora/Manrope for headings, Inter for body) via google_fonts, full scale (Display/H1/H2/H3/Body/Caption/Button) with fixed weights, sizes, and line-heights.
AppSpacing: a fixed spacing scale (4/8/12/16/24/32/48) used everywhere — no arbitrary padding values scattered in widgets.
AppRadius & AppElevation: fixed corner-radius scale (e.g. 16/20/24) and 3–4 glass elevation levels (blur 8–20px, fill opacity 8–15%, 1px 20%-opacity border, soft shadow).

5.2 Backgrounds

Multi-stop prism gradient background, subtle and not overpowering text/content. Optional slow ambient shimmer/animation on splash and welcome screens only (not on every screen — avoid visual fatigue).

5.3 Components (each defined once, reused everywhere)

Buttons: primary (filled gradient + glass highlight), secondary (glass outline), ghost/text — each with distinct hover/pressed/disabled/loading states and haptic feedback on mobile.
Cards/containers: consistent glass styling per the elevation system above.
Inputs: glass field with floating label, clear focus ring, inline validation/error text.
Navigation: glass-blurred bottom nav/drawer with animated active indicator, smooth icon transitions.
Splash/Welcome/Onboarding: redesign as the strongest first impression — gradient background, glass logo/card, fade+slide entrance animation, modern progress indicator, clear single primary CTA button (not multiple competing buttons).
Icons: one consistent icon family, consistent stroke weight and sizing.

5.4 Alignment & polish pass (do this as a dedicated, explicit step)

Go screen by screen and check: consistent left/right margins, vertical rhythm between elements, button widths/heights matching across similar screens, text not clipped/overflowing, safe-area respected on all device sizes, no element touching screen edges without intended padding.
Test on at least: small phone, large phone/tablet, and a resized desktop window (for Windows) to confirm responsive layout holds up.

5.5 Micro-interactions

Button scale/opacity feedback on tap.
Smooth page transitions (fade-through or shared-axis, not abrupt cuts).
Skeleton loaders instead of bare spinners for content-heavy screens.

6. VERIFICATION GATE (must ALL pass before any installer/APK is built)

Do not proceed to Phase 7 until every item below is checked off and confirmed working:

 flutter analyze returns 0 issues
 flutter doctor -v clean for the active target platform
 App builds and launches in debug AND release mode with no errors
 Every interactive element from Section 3.3's checklist confirmed working
 Every navigation route confirmed reachable and returnable
 All backend endpoints confirmed reachable with correct data and proper error handling
 Performance budget (Section 4) measured and met
 No console errors/warnings during a full click-through of the app
 Design system (Section 5) applied consistently on every screen — no leftover default Flutter styling
 Tested edge cases (no internet, slow network, empty states, rapid taps) all handled gracefully

If anything fails, fix it and re-run the full gate from the top — do not patch and assume.

7. CLEANUP (after the gate passes, before final build)

Remove unused imports, dead code, commented-out blocks, unused assets/fonts, unused Python modules.
flutter clean; delete build/, .dart_tool/; remove Python __pycache__, .pyc, stale .venv artifacts not in use.
Remove any old/duplicate build scripts superseded by Section 2's unified scripts.
Re-confirm nothing referenced was deleted (project-wide search before deleting).

8. FINAL BUILD (only now)

Run the single active script (build_windows.bat or build_android.bat) per the target_platform value.
Windows: confirm Inno Setup produces a working installer at /dist/windows/AppName-Setup.exe; test-install it and launch the installed app to confirm it runs correctly outside the dev environment.
Android: confirm the signed release APK/AAB installs and runs correctly on a real or virtual device.

9. FINAL REPORT (required output format)

Platform switch test — proof both windows and android values were tested and only the intended one built.
Full list of bugs found and fixed (with file names).
Full list of dead/junk files removed.
Before/after UI summary per screen (what changed, why).
Performance numbers measured vs. the budget in Section 4.
Verification gate checklist — fully checked.
Final installer/APK path and confirmation it was test-installed and runs cleanly.


