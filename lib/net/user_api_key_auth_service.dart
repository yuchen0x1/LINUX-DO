import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import '../utils/log.dart';
import '../utils/storage_manager.dart';

class UserApiKeyAuthService {
  static final UserApiKeyAuthService _instance = UserApiKeyAuthService._internal();
  factory UserApiKeyAuthService() => _instance;
  UserApiKeyAuthService._internal();

  static const String keyUserApiKey = 'discourse_user_api_key';
  static const String keyUserPublicKey = 'discourse_user_public_key';
  static const String keyUserPrivateKey = 'discourse_user_private_key';

  /// 获取已持久化的 User API Key
  String? get apiKey => StorageManager.getString(keyUserApiKey);

  /// 是否已经通过官方 User API Key 授权
  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  /// 保存 Key
  Future<void> saveApiKey(String key) async {
    await StorageManager.setData(keyUserApiKey, key);
  }

  /// 清除 Key
  Future<void> clearApiKey() async {
    await StorageManager.remove(keyUserApiKey);
    await StorageManager.remove(keyUserPublicKey);
    await StorageManager.remove(keyUserPrivateKey);
  }

  /// 生成 RSA 密钥对
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRsaKeyPair() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom,
      ));

    final pair = keyGen.generateKeyPair();
    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    // 格式化为标准 PEM 公钥
    final pem = _encodePublicKeyToPem(myPublic);
    StorageManager.setData(keyUserPublicKey, pem);

    // 保存私钥参数 (n, d)
    StorageManager.setData(
        keyUserPrivateKey, json.encode({'modulus': myPrivate.modulus.toString(), 'privateExponent': myPrivate.privateExponent.toString()}));

    return AsymmetricKeyPair(myPublic, myPrivate);
  }

  /// 生成跳转 Discourse 的 User API Key 授权链接
  String buildAuthUrl({
    required String baseUrl,
    required String applicationName,
    required String clientId,
    required String publicKeyPem,
  }) {
    final scopes = 'read,write,notifications,message_bus';
    final nonce = Random().nextInt(1000000).toString();
    final uri = Uri.parse('$baseUrl/user-api-key/new').replace(queryParameters: {
      'application_name': applicationName,
      'client_id': clientId,
      'scopes': scopes,
      'public_key': publicKeyPem,
      'nonce': nonce,
      'auth_redirect': 'linuxdo://auth/callback',
    });
    return uri.toString();
  }

  /// 使用私钥解密服务端传回的加密 payload
  String decryptPayload(String encryptedBase64) {
    try {
      final privJson = StorageManager.getString(keyUserPrivateKey);
      if (privJson == null) throw Exception('私钥未找到');

      final data = json.decode(privJson);
      final privateKey = RSAPrivateKey(
        BigInt.parse(data['modulus']),
        BigInt.parse(data['privateExponent']),
        null,
        null,
      );

      final cipher = PKCS1Encoding(RSAEngine())..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
      final encryptedBytes = base64.decode(encryptedBase64);
      final decryptedBytes = cipher.process(encryptedBytes);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      l.e('解密 User API Key payload 失败: $e');
      rethrow;
    }
  }

  String _encodePublicKeyToPem(RSAPublicKey publicKey) {
    // 简易 ASN.1 DER 封装
    final modulus = publicKey.modulus!;
    final exponent = publicKey.exponent!;
    final modulusBytes = _encodeBigInt(modulus);
    final exponentBytes = _encodeBigInt(exponent);

    final rsaSeq = _encodeSequence([
      Uint8List.fromList([0x02, modulusBytes.length, ...modulusBytes]),
      Uint8List.fromList([0x02, exponentBytes.length, ...exponentBytes]),
    ]);

    final rsaOid = Uint8List.fromList([
      0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00
    ]);

    final bitString = Uint8List.fromList([0x03, rsaSeq.length + 1, 0x00, ...rsaSeq]);
    final outerSeq = _encodeSequence([rsaOid, bitString]);

    final base64Key = base64.encode(outerSeq);
    return '-----BEGIN PUBLIC KEY-----\n$base64Key\n-----END PUBLIC KEY-----';
  }

  Uint8List _encodeSequence(List<Uint8List> elements) {
    final body = <int>[];
    for (var elem in elements) {
      body.addAll(elem);
    }
    return Uint8List.fromList([0x30, body.length, ...body]);
  }

  List<int> _encodeBigInt(BigInt number) {
    int bytes = (number.bitLength + 7) >> 3;
    var b256 = BigInt.from(256);
    var result = Uint8List(bytes);
    for (int i = 0; i < bytes; i++) {
      result[bytes - 1 - i] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    if (result.isNotEmpty && result[0] >= 128) {
      return [0x00, ...result];
    }
    return result;
  }
}
