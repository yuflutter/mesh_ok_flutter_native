import 'dart:convert';

import 'platform_result.dart';

/// Группа запрашивается, но пока никак не используется.
class WifiP2PGroup extends PlatformResult {
  WifiP2PGroup.fromJson(super.json) : super.fromJson();

  /// Группа может приходить как null, или как пустой Map, см коммент в котлине.
  static WifiP2PGroup? fromNullableJson(String json) {
    final res = jsonDecode(json);
    return (res != null && res is Map && res.entries.isNotEmpty) ? WifiP2PGroup.fromJson(json) : null;
  }
}
