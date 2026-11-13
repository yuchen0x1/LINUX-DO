import 'package:dio/dio.dart';

import 'http_config.dart';
import 'proxy_failover_interceptor.dart';
import 'proxy_service.dart';

/// 图片下载使用同一线路，但不向外部图片站附带论坛的登录凭据。
class MediaClient {
  static final Dio dio = _create();

  static Dio _create() {
    final proxy = ProxyService();
    final client = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: HttpConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: HttpConfig.receiveTimeout),
      ),
    );
    proxy.applyToDio(client);
    client.interceptors.add(
      ProxyFailoverInterceptor(
        dio: client,
        enabled: () => proxy.isEnabled && proxy.isSubscription,
        recover: () => proxy.recover(),
        currentNode: () => proxy.selectedNodeId,
        recoverFrom: (node) => proxy.recover(failedNodeId: node),
        maxAttempts: () => proxy.nodeCount,
      ),
    );
    return client;
  }
}
