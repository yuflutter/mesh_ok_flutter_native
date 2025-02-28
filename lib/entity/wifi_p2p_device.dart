import 'dart:convert';
import 'platform_result.dart';
import 'peer_status.dart';

export 'peer_status.dart';

class WifiP2pDevice extends PlatformResult {
  late final String deviceName;
  late final String deviceAddress;
  late final String primaryDeviceType;
  late final PeerStatus status;

  WifiP2pDevice.fromJson(super.json) : super.fromJson() {
    deviceName = all['deviceName'] as String;
    deviceAddress = all['deviceAddress'] as String;
    primaryDeviceType = all['primaryDeviceType'] as String? ?? '';
    status = PeerStatus.fromId(all['status'] as int);
  }

  /// Может приходить как null, или как пустой Map, см коммент в котлине.
  static WifiP2pDevice? fromNullableJson(String json) {
    final res = jsonDecode(json);
    return (res != null && res is Map && res.entries.isNotEmpty) ? WifiP2pDevice.fromJson(json) : null;
  }
}
