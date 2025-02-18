import 'platform_result.dart';
import 'peer_status.dart';

export 'peer_status.dart';

class Peer extends PlatformResult {
  late final String deviceName;
  late final String deviceAddress;
  late final PeerStatus status;

  Peer.fromJson(super.json) : super.fromJson() {
    deviceName = all['deviceName'] as String;
    deviceAddress = all['deviceAddress'] as String;
    status = PeerStatus.fromId(all['status'] as int);
  }
}
