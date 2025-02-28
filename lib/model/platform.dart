import 'package:flutter/services.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/wifi_p2p_device.dart';
import '/entity/wifi_p2p_group.dart';

const _androidChannelName = "WifiP2pMethodChannel";

class Platform {
  final void Function(List) onPeersDiscovered;
  final void Function(String) onP2pInfoChanged;

  final _channel = MethodChannel(_androidChannelName);
  final _log = global<Logger>();

  Platform({
    required this.onPeersDiscovered,
    required this.onP2pInfoChanged,
  }) {
    _channel.setMethodCallHandler((call) async {
      try {
        _log.i('Received call: $call', consoleOnly: true);
        return switch (call.method) {
          'onPeersDiscovered' => onPeersDiscovered(call.arguments as List),
          'onP2pInfoChanged' => onP2pInfoChanged(call.arguments as String),
          _ => throw 'Unknown method received: ${call.method}',
        };
      } catch (e, s) {
        _log.e(this, e, s);
      }
    });
  }

  Future<void> init() => _dowl('init');
  Future<WifiP2pDevice> requestDeviceInfo() async => WifiP2pDevice.fromJson(await _dowl('requestDeviceInfo'));
  Future<void> requestConnectionInfo() => _dowl('requestConnectionInfo');
  Future<WifiP2PGroup?> requestGroupInfo() async => WifiP2PGroup.fromNullableJson(await _dowl('requestGroupInfo'));
  Future<void> discoverPeers() => _dowl('discoverPeers');
  Future<void> connectPeer(WifiP2pDevice peer) => _dowl('connectPeer', peer.deviceAddress);
  Future<void> disconnectMe() => _dowl('disconnectMe');

  // Выполняет функцию и логирует её вызов и результат (do with log)
  Future _dowl(String methodName, [dynamic arguments]) async {
    final res = await _channel.invokeMethod(methodName, arguments);
    _log.i('$methodName(${arguments ?? ''}) => $res');
    return res;
  }

  void close() => _channel.setMethodCallHandler(null);
}
