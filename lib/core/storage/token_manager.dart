import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// المكان الوحيد المسموح له يلمس التخزين الآمن للتوكنات.
/// كل باقي التطبيق يتعامل معه، مش مع FlutterSecureStorage مباشرة.
class TokenManager {
  static const String _keyAccessToken = 'wasla_access_token';
  static const String _keyRefreshToken = 'wasla_refresh_token';

  final FlutterSecureStorage _storage;

  TokenManager([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  // كاش بالذاكرة لتفادي قراءة القرص بكل طلب
  String? _cachedAccessToken;

  // قفل يمنع طلبين متزامنين من تجديد التوكن بنفس اللحظة
  Completer<bool>? _refreshCompleter;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _cachedAccessToken ??= await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  /// أي كود بدو يجدد الجلسة ينادي هاي بدل ما يتصل بالـ API مباشرة.
  /// لو فيه عملية تجديد شغّالة أصلاً، بيستنى نتيجتها بدل ما يبعت طلب موازي.
  Future<bool> refreshSession(
    Future<bool> Function(String refreshToken) doRefresh,
  ) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final rt = await getRefreshToken();
      if (rt == null || rt.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }
      final ok = await doRefresh(rt);
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(ok);
      }
      return ok;
    } catch (_) {
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
