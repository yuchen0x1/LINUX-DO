import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'log.dart';
import 'storage_manager.dart';

/// 敏感数据存储。
///
/// 把 User API Key、RSA 私钥这类「泄露即可长期冒用身份」的数据放进系统密钥库
/// （Android Keystore / iOS Keychain / macOS Keychain），而不是明文的
/// SharedPreferences。
///
/// 设计要点：
/// - **同步读**：调用方（拦截器、解密流程）原本就是同步读取，这里用内存缓存
///   维持同步接口，避免把异步传染到整条调用链。
/// - **自动迁移**：启动时若密钥库里没有、而旧版 SharedPreferences 里有，就搬到
///   密钥库并从 SharedPreferences 删除。
/// - **可降级**：密钥库在极端环境下可能不可用（如 Keystore 损坏），此时退回
///   普通存储并打警告，保证 App 不会因此无法登录，但绝不静默。
class SecureStore {
  SecureStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static final Map<String, String?> _cache = {};
  static bool _ready = false;

  /// 密钥库是否可用。不可用时降级为 SharedPreferences。
  static bool _secureAvailable = true;

  static bool get isSecureAvailable => _secureAvailable;

  /// 加载指定 key 到内存缓存，并顺带完成旧数据迁移。
  ///
  /// 必须在任何同步读取之前 await 一次。重复调用安全。
  static Future<void> init(Iterable<String> keys) async {
    if (_ready) return;
    for (final key in keys) {
      _cache[key] = await _load(key);
    }
    _ready = true;
  }

  /// 同步读取（来自内存缓存）。未 init 或不存在时返回 null。
  static String? get(String key) => _cache[key];

  static Future<void> set(String key, String value) async {
    _cache[key] = value;

    if (!_secureAvailable) {
      await StorageManager.setData(key, value);
      return;
    }

    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      _secureAvailable = false;
      l.w('密钥库写入失败，降级为普通存储: $e');
      await StorageManager.setData(key, value);
    }
  }

  static Future<void> remove(String key) async {
    _cache.remove(key);

    // 明文副本无论密钥库是否可用都要清掉
    await StorageManager.remove(key);

    if (!_secureAvailable) return;
    try {
      await _storage.delete(key: key);
    } catch (e) {
      l.w('密钥库删除 $key 失败: $e');
    }
  }

  static Future<String?> _load(String key) async {
    if (_secureAvailable) {
      try {
        final secure = await _storage.read(key: key);
        if (secure != null && secure.isNotEmpty) return secure;
      } catch (e) {
        _secureAvailable = false;
        l.w('密钥库读取失败，降级为普通存储: $e');
      }
    }

    // 旧版本明文数据：搬到密钥库并从 SharedPreferences 删除
    final legacy = StorageManager.getString(key);
    if (legacy == null || legacy.isEmpty) return null;

    if (_secureAvailable) {
      try {
        await _storage.write(key: key, value: legacy);
        await StorageManager.remove(key);
        l.i('已把 $key 迁移到系统密钥库');
      } catch (e) {
        l.w('迁移 $key 到密钥库失败，暂留明文: $e');
      }
    }
    return legacy;
  }
}
