import 'dart:async';
import 'dart:io';

/// Routes default Dart HTTP clients (including Flutter network images) through
/// the same app-only proxy as API requests and WebViews.
class ProxyHttpOverrides extends HttpOverrides {
  ProxyHttpOverrides({required this.findProxy, this.previous});

  String Function(Uri) findProxy;
  final HttpOverrides? previous;

  /// A Zone-specific override remains authoritative, for example in tests.
  /// Preserve an existing global client's other settings and security context.
  static void install({required String Function(Uri) findProxy}) {
    final previous = Zone.root.run(() => HttpOverrides.current);
    if (previous is ProxyHttpOverrides) {
      previous.findProxy = findProxy;
    } else {
      HttpOverrides.global = ProxyHttpOverrides(
        findProxy: findProxy,
        previous: previous,
      );
    }
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // super constructs the real client directly; calling HttpClient() here
    // would re-enter this override. Callers may still explicitly set DIRECT
    // for the subscription bootstrap and the loopback core controller.
    final client =
        previous?.createHttpClient(context) ?? super.createHttpClient(context);
    client.findProxy = (uri) => findProxy(uri);
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) =>
      previous?.findProxyFromEnvironment(url, environment) ??
      super.findProxyFromEnvironment(url, environment);
}
