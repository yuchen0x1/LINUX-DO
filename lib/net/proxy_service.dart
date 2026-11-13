import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide AndroidOptions;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'cronet_adapter.dart';
import 'proxy_subscription.dart';
import 'subscription_proxy_core.dart';
import '../utils/storage_manager.dart';

abstract class SubscriptionSettingsStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> remove();
}

class SecureSubscriptionSettingsStore implements SubscriptionSettingsStore {
  static const _key = 'proxy_subscription_v1';
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> remove() => _storage.delete(key: _key);
}

/// A single app-only route shared by Dio and Android WebViews.
/// The subscription's remote rules/listeners never become app configuration.
class ProxyService extends ChangeNotifier {
  static final ProxyService _instance = ProxyService._();
  factory ProxyService() => _instance;
  ProxyService._()
    : _core = AndroidSubscriptionProxyCore(),
      _store = SecureSubscriptionSettingsStore();

  @visibleForTesting
  ProxyService.forTesting({
    required SubscriptionProxyCore core,
    required SubscriptionSettingsStore store,
    required Future<String> Function(Uri) download,
    required Future<void> Function() applyWebView,
  }) : _core = core,
       _store = store,
       _downloadOverride = download,
       _webViewOverride = applyWebView;

  static const keyEnabled = 'http_proxy_enabled';
  static const keyHost = 'http_proxy_host';
  static const keyPort = 'http_proxy_port';
  static const keyMode = 'proxy_route_mode';
  final SubscriptionProxyCore _core;
  final SubscriptionSettingsStore _store;
  Future<String> Function(Uri)? _downloadOverride;
  Future<void> Function()? _webViewOverride;
  final Set<Dio> _clients = {};
  ProxySubscription? _subscription;
  String _url = '';
  String _text = '';
  String? _selected;
  Map<String, int> _delays = {};
  final Set<String> _failedNodes = {};
  bool _exhausted = false;
  Timer? _monitor;
  Future<bool>? _recovery;
  bool _busy = false;
  int _generation = 0;
  DateTime? _lastProbe;
  String? errorMessage;
  void Function(String message)? onAllNodesFailed;
  String progressLabel = '正在导入并检测节点…';

  bool get isEnabled => StorageManager.getBool(keyEnabled) ?? false;
  bool get isSubscription =>
      StorageManager.getString(keyMode) == 'subscription';
  bool get isBusy => _busy;
  bool get isRecovering => _recovery != null;
  String get subscriptionUrl => _url;
  int get nodeCount => _subscription?.nodes.length ?? 0;
  int get skippedCount => _subscription?.skipped ?? 0;
  String get host =>
      isSubscription ? '127.0.0.1' : StorageManager.getString(keyHost) ?? '';
  // Fail closed when a chosen subscription cannot start; never silently go direct.
  String get port => isSubscription
      ? '${_core.port ?? 1}'
      : StorageManager.getString(keyPort) ?? '';
  bool get hasValidRule =>
      isEnabled &&
      (isSubscription ||
          (host.trim().isNotEmpty && int.tryParse(port) != null));
  bool get isConnected =>
      hasValidRule &&
      (!isSubscription ||
          (_selected != null && errorMessage == null && _core.port != null));
  String get dioRule => 'PROXY ${host.trim()}:${port.trim()}';
  String? get selectedNodeName {
    for (final node in _subscription?.nodes ?? <SubscriptionNode>[]) {
      if (node.id == _selected) return node.name;
    }
    return null;
  }

  int? get selectedDelay => _delays[_selected];
  String? get selectedNodeId => _selected;
  String get statusLabel {
    if (!isEnabled) return '直连';
    if (_busy) return '正在连接';
    if (isRecovering) return '正在自动切换';
    if (isSubscription)
      return isConnected ? '自动选线 · ${selectedNodeName ?? "已连接"}' : '暂无可用线路';
    return hasValidRule ? '手动代理' : '未配置';
  }

  static String sanitizeHost(String raw) {
    var value = raw.trim().replaceFirst(RegExp(r'^https?://'), '');
    return value.split('/').first.trim();
  }

  Future<void> initialize() async {
    try {
      final record = await _store.read();
      if (record != null) {
        final data = jsonDecode(record) as Map<String, dynamic>;
        _url = data['url'] as String;
        _text = data['text'] as String;
        _subscription = ProxySubscription.parse(_text);
      }
      if (isEnabled && isSubscription) {
        if (_subscription == null) throw const SubscriptionException('请重新导入订阅');
        await _core.start(_subscription!.coreConfiguration());
        _startMonitor();
        unawaited(recover(avoidCurrent: false));
      }
      await applyToWebView();
    } catch (_) {
      if (isEnabled && isSubscription) errorMessage = '线路恢复失败，请重新导入订阅';
    }
    notifyListeners();
  }

  Future<String> _download(Uri uri) async {
    if (_downloadOverride != null) return _downloadOverride!(uri);
    try {
      return await _downloadVia(uri, 'DIRECT');
    } catch (_) {
      if (!hasValidRule || (isSubscription && _core.port == null)) rethrow;
      return _downloadVia(uri, dioRule);
    }
  }

  Future<String> _downloadVia(Uri uri, String route) async {
    if (route == 'DIRECT' && Platform.isAndroid)
      return _downloadWithCronet(uri);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..findProxy = (_) => route;
    Future<String> read() async {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'clash.meta/1.19.34');
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/yaml,text/yaml,text/plain,*/*',
      );
      final response = await request.close();
      if (response.statusCode != 200) {
        throw const SubscriptionException('订阅下载失败，请检查链接是否有效');
      }
      if (response.contentLength > ProxySubscription.maxBytes) {
        throw const SubscriptionException('订阅超过 2 MB');
      }
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
        if (bytes.length > ProxySubscription.maxBytes) {
          throw const SubscriptionException('订阅超过 2 MB');
        }
      }
      return utf8.decode(bytes);
    }

    try {
      return await read().timeout(const Duration(seconds: 25));
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _downloadWithCronet(Uri uri) async {
    final dio = Dio(
      BaseOptions(
        headers: {
          HttpHeaders.userAgentHeader: 'clash.meta/1.19.34',
          HttpHeaders.acceptHeader: 'application/yaml,text/yaml,text/plain,*/*',
        },
      ),
    )..httpClientAdapter = CronetHttpClientAdapter();
    Future<String> read() async {
      final response = await dio.get<ResponseBody>(
        uri.toString(),
        options: Options(responseType: ResponseType.stream),
      );
      final bytes = <int>[];
      await for (final chunk in response.data!.stream) {
        bytes.addAll(chunk);
        if (bytes.length > ProxySubscription.maxBytes) {
          throw const SubscriptionException('订阅超过 2 MB');
        }
      }
      return utf8.decode(bytes);
    }

    try {
      return await read().timeout(const Duration(seconds: 25));
    } finally {
      dio.close(force: true);
    }
  }

  Future<void> importSubscription(String rawUrl) async {
    if (_busy) throw const SubscriptionException('正在更新线路，请稍等');
    final uri = ProxySubscription.parseUrl(rawUrl);
    _busy = true;
    final generation = ++_generation;
    notifyListeners();
    final previous = _subscription;
    final previousText = _text;
    final previousUrl = _url;
    var changedCore = false;
    var failureMessage = '订阅下载失败，请检查网络和链接后重试';
    try {
      progressLabel = '正在下载订阅…';
      notifyListeners();
      final text = await _download(uri);
      final subscription = ProxySubscription.parse(text);
      // Secure storage must work before replacing a live route.
      failureMessage = '无法安全保存订阅，请检查手机存储后重试';
      progressLabel = '正在保存线路…';
      notifyListeners();
      await _store.write(jsonEncode({'url': uri.toString(), 'text': text}));
      try {
        failureMessage = '订阅已读取，但节点配置无法启动，请检查或更换订阅';
        progressLabel = '正在连接线路…';
        notifyListeners();
        await _core.start(subscription.coreConfiguration());
        changedCore = true;
      } catch (_) {
        if (previous != null) {
          await _store.write(
            jsonEncode({'url': previousUrl, 'text': previousText}),
          );
        } else {
          await _store.remove();
        }
        rethrow;
      }
      _subscription = subscription;
      _text = text;
      _url = uri.toString();
      _selected = null;
      _delays = {};
      _failedNodes.clear();
      _exhausted = false;
      errorMessage = null;
      await StorageManager.setData(keyMode, 'subscription');
      await StorageManager.setData(keyEnabled, true);
      failureMessage = '线路已加载，但无法应用代理，请重新连接';
      await _applyConsumers();
      progressLabel = '正在检测节点…';
      notifyListeners();
      await _checkNodes(generation: generation);
      _startMonitor();
    } on SubscriptionException {
      rethrow;
    } catch (_) {
      if (changedCore && previous != null) {
        try {
          _subscription = previous;
          _text = previousText;
          _url = previousUrl;
          await _core.start(previous.coreConfiguration());
          await _applyConsumers();
        } catch (_) {
          errorMessage = '线路恢复失败，请重新连接';
        }
      }
      throw SubscriptionException(failureMessage);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> disable() async {
    if (_busy) throw const SubscriptionException('正在更新线路，请稍等');
    ++_generation;
    _monitor?.cancel();
    _monitor = null;
    await StorageManager.setData(keyEnabled, false);
    try {
      await _core.stop();
    } catch (_) {}
    _selected = null;
    _delays = {};
    errorMessage = null;
    await _applyConsumers();
    notifyListeners();
  }

  /// Keep existing manual HTTP proxy configurations available as an advanced option.
  Future<void> save({
    required bool enabled,
    required String host,
    required String port,
  }) async {
    if (!enabled) {
      await disable();
      return;
    }
    if (_busy) throw const SubscriptionException('正在更新线路，请稍等');
    final cleanHost = sanitizeHost(host);
    final number = int.tryParse(port.trim());
    if (cleanHost.isEmpty ||
        RegExp(r'[\s;]').hasMatch(cleanHost) ||
        number == null ||
        number < 1 ||
        number > 65535) {
      throw const SubscriptionException('请填写正确的代理主机和端口');
    }
    ++_generation;
    _monitor?.cancel();
    _monitor = null;
    try {
      await _core.stop();
    } catch (_) {}
    await StorageManager.setData(keyHost, cleanHost);
    await StorageManager.setData(keyPort, '$number');
    await StorageManager.setData(keyMode, 'manual');
    await StorageManager.setData(keyEnabled, true);
    errorMessage = null;
    await _applyConsumers();
    notifyListeners();
  }

  void _startMonitor() {
    _monitor?.cancel();
    if (_exhausted || !isEnabled || !isSubscription) return;
    _monitor = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!isEnabled || !isSubscription || _busy || _recovery != null) return;
      if (_lastProbe == null ||
          DateTime.now().difference(_lastProbe!).inSeconds >= 60 ||
          errorMessage != null) {
        await recover(avoidCurrent: false);
      } else {
        try {
          _selected = await _core.currentNode();
          notifyListeners();
        } catch (_) {
          await recover(avoidCurrent: false);
        }
      }
    });
  }

  Future<bool> recover({bool avoidCurrent = true, String? failedNodeId}) {
    if (!isEnabled || !isSubscription || _subscription == null || _busy)
      return Future.value(false);
    if (_recovery != null) return _recovery!;
    if (_exhausted) return Future.value(false);
    if (avoidCurrent && failedNodeId != null && failedNodeId.isNotEmpty) {
      _failedNodes.add(failedNodeId);
    }
    // A late error from a previous route must not discard the new healthy node.
    if (avoidCurrent &&
        failedNodeId != null &&
        failedNodeId != _selected &&
        isConnected) {
      return Future.value(true);
    }
    final generation = _generation;
    final excluded = avoidCurrent ? (failedNodeId ?? _selected) : null;
    if (excluded != null) _failedNodes.add(excluded);
    final future = _checkNodes(generation: generation, useCached: avoidCurrent);
    _recovery = future;
    notifyListeners();
    return future.whenComplete(() {
      if (identical(_recovery, future)) _recovery = null;
      notifyListeners();
    });
  }

  Future<bool> recheck() async {
    _failedNodes.clear();
    _exhausted = false;
    final result = await recover(avoidCurrent: false);
    _startMonitor();
    return result;
  }

  Future<bool> _checkNodes({int? generation, bool useCached = false}) async {
    final expectedGeneration = generation ?? _generation;
    try {
      if (_core.port == null && _subscription != null) {
        await _core.start(_subscription!.coreConfiguration());
        if (expectedGeneration != _generation) return false;
        await _applyConsumers();
      }
      Map<String, int> delays;
      try {
        delays = useCached && _delays.isNotEmpty
            ? _delays
            : await _core.probe();
      } on DioException catch (error) {
        if (error.type != DioExceptionType.connectionError ||
            _subscription == null ||
            expectedGeneration != _generation)
          rethrow;
        await _core.start(_subscription!.coreConfiguration());
        if (expectedGeneration != _generation) return false;
        await _applyConsumers();
        delays = await _core.probe();
      }
      if (expectedGeneration != _generation || !isEnabled || !isSubscription)
        return false;
      _lastProbe = DateTime.now();
      _delays = delays;
      final available =
          (_subscription?.nodes ?? <SubscriptionNode>[])
              .where((node) => delays.containsKey(node.id))
              .where((node) => !_failedNodes.contains(node.id))
              .toList()
            ..sort((a, b) => delays[a.id]!.compareTo(delays[b.id]!));
      if (available.isEmpty) {
        _selected = null;
        final firstFailure = !_exhausted;
        _exhausted = true;
        _monitor?.cancel();
        _monitor = null;
        errorMessage = '全部节点连接失败，请更新或更换订阅';
        try {
          await _core.select('REJECT');
        } catch (_) {}
        if (firstFailure) onAllNodesFailed?.call(errorMessage!);
        notifyListeners();
        return false;
      }
      var best = available.first;
      if (!useCached &&
          _selected != null &&
          !_failedNodes.contains(_selected) &&
          delays.containsKey(_selected) &&
          delays[_selected]! <= delays[best.id]! + 80) {
        best = available.firstWhere((node) => node.id == _selected);
      }
      await _core.select(best.id);
      if (expectedGeneration != _generation) return false;
      final changedNode = _selected != best.id;
      _selected = best.id;
      errorMessage = null;
      if (changedNode) {
        // New reads must not reuse an idle tunnel belonging to the previous node.
        for (final client in _clients.toList()) {
          applyToDio(client);
        }
      }
      notifyListeners();
      return true;
    } catch (_) {
      if (expectedGeneration == _generation && isEnabled && isSubscription) {
        errorMessage = '节点检测未成功，将自动重试';
        notifyListeners();
      }
      return false;
    }
  }

  Future<void> _applyConsumers() async {
    for (final client in _clients.toList()) {
      applyToDio(client);
    }
    await applyToWebView();
  }

  void applyToDio(Dio dio) {
    _clients.add(dio);
    final previous = dio.httpClientAdapter;
    if (hasValidRule) {
      final rule = dioRule;
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          // Let the proxy resolve the destination. A custom direct socket factory
          // here would bypass the proxy when DoH is enabled.
          return HttpClient()..findProxy = (_) => rule;
        },
      );
    } else {
      dio.httpClientAdapter = CronetHttpClientAdapter();
    }
    previous.close(force: false);
  }

  Future<void> applyToWebView() async {
    if (_webViewOverride != null) return _webViewOverride!();
    if (!Platform.isAndroid) return;
    final controller = ProxyController();
    if (hasValidRule) {
      await controller.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: '${host.trim()}:${port.trim()}')],
          bypassRules: ['<-loopback>'],
        ),
      );
    } else {
      await controller.clearProxyOverride();
    }
  }

  @override
  void dispose() {
    _monitor?.cancel();
    _clients.clear();
    super.dispose();
  }
}
