# Local compatibility patch

- Upstream: https://github.com/Sub6Resources/flutter_html
- Published source: https://pub.dev/packages/flutter_html/versions/3.0.0
- Archive: https://pub.dev/api/archives/flutter_html-3.0.0.tar.gz
- Verified archive SHA-256: `38a2fd702ffdf3243fb7441ab58aa1bc7e6922d95a50db76534de8260638558d`
- License: MIT, preserved in `LICENSE` with the upstream copyright notice.

Only the runtime `lib/` tree, package metadata, README, CHANGELOG and license were
imported. Examples, screenshots, tests and repository automation are not vendored.

`lib/src/tree/styled_element.dart` imports the existing csslib parser and replaces
the removed `html/src/query_selector.dart` top-level `matches` call with a parsed
selector group passed to `SelectorEvaluator().matches`. Null groups return false;
the upstream exception handling remains unchanged. No global Pub cache is edited.

The application pins html 0.15.7, retains that release's parser/security fixes and
tests class, descendant/child, attribute and nonmatching/empty selector behavior
in `test/html_selector_compat_test.dart`.

This is a temporary source patch until an upstream release removes this private
API dependency; review that migration together with the selector tests.
