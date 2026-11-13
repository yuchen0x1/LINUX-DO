# LINUX DO Android

A Flutter client for the LINUX DO community. This branch maintains **Android only**.
Historical iOS, macOS, Windows and Web projects are no longer part of the active working tree.

## Latest update

### v1.1.1 · 2026-11-13

- Maintain Android only and remove obsolete platform/build files from the source tree.
- Complete historical release notes and correct version/feature attribution.
- Align the build environment with the SDK required by existing dependencies.
- Add repository upload checks and keep release diagnostics separate from APKs.

See the [complete release history](docs/releases/release-notes.md).
The current source version is `1.1.1+13`; this is an Android maintenance release.

## Download

Download Android APKs from [GitHub Releases](https://github.com/yuchen0x1/LINUX-DO/releases).

- `arm64-v8a`: most modern Android phones.
- `armeabi-v7a`: older 32-bit Android devices.
- `x86_64`: Android emulators or x86 Android devices, not a Windows build.

## Development

CI pins Flutter 3.47.1 stable and Java 17. Dart must be >=3.13.0 and <4.0.0.
Commit `pubspec.lock` and keep signing credentials local.

```bash
git clone https://github.com/yuchen0x1/LINUX-DO.git
cd LINUX-DO
flutter pub get
flutter devices
flutter run -d <android-device-id>
python3 scripts/check_repository_hygiene.py
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub
flutter build apk --release --split-per-abi
```

Release signing reads `android/keystore/key.properties`. Without complete signing configuration,
the current Gradle setup produces an unsigned package; that is not evidence of a distributable build.
Never commit keystores, passwords, local environment files, APKs, caches or local archives.

`dist/` contains local release packages and diagnostics. `.local-archive/` contains retired files
and recoverable backups. Both are ignored by Git and excluded from application assets.
See [repository hygiene](docs/REPOSITORY_HYGIENE.md) and [contribution guidelines](CONTRIBUTING.md).

Feature descriptions are based on source code. Live-account behavior, all device combinations,
offline reading, silent installation and other platforms are not claimed as verified capabilities.
Sensitive keys prefer Android secure storage; a fallback to ordinary storage still exists when secure storage is unavailable.

## Attribution and license

Based on the history of [R-lz/LINUX-DO](https://github.com/R-lz/LINUX-DO).
MIT; retain the notices in [LICENSE](LICENSE).
