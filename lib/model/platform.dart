import 'package:flutter/services.dart';

import '/core/global.dart';
import '/core/logger.dart';

const _androidChannelName = "WifiP2pMethodChannel";

class Platform {
  final channel = MethodChannel(_androidChannelName);
  final void Function(List) onPeersDiscovered;
  final void Function(String) onP2pInfoChanged;

  Platform({required this.onPeersDiscovered, required this.onP2pInfoChanged}) {
    channel.setMethodCallHandler((call) async {
      final logger = global<Logger>();
      try {
        logger.info('Received call: $call', consoleOnly: true);
        return switch (call.method) {
          'onPeersDiscovered' => onPeersDiscovered(call.arguments as List),
          'onP2pInfoChanged' => onP2pInfoChanged(call.arguments as String),
          _ => throw 'Unknown method received: ${call.method}',
        };
      } catch (e, s) {
        logger.error(this, e, s);
      }
    });
  }

  Future init() => channel.invokeMethod('init');
  Future discoverPeers() => channel.invokeMethod('discoverPeers');
  Future connectPeer(String deviceAddress) => channel.invokeMethod('connectPeer', deviceAddress);
  Future disconnectMe() => channel.invokeMethod('disconnectMe');

  void close() => channel.setMethodCallHandler(null);
}
