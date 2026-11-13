# Android compatibility subset

- Upstream: https://github.com/hui-z/image_gallery_saver
- Version: 2.0.3
- Archive: https://pub.dev/api/archives/image_gallery_saver-2.0.3.tar.gz
- Verified archive SHA-256: `0aba74216a4d9b0561510cb968015d56b701ba1bd94aace26aacdd8ae5761816`
- License: MIT, retained verbatim in `LICENSE`.

Imported only Dart runtime source, Android `src/`, Android build.gradle, package
metadata and upstream documentation. The application maintains Android only;
the omitted iOS implementation is removed from this local package's platform
declaration. Gradle wrappers and example projects are not imported.

The sole Kotlin source change removes an unused `PluginRegistry.Registrar`
import, whose API was removed from current Flutter SDKs. The existing v2
`FlutterPlugin` implementation and Dart/MethodChannel interface are unchanged.
Documentation whitespace is normalized. No shared Pub cache is patched.
