import 'native_dto.dart';
import 'peer_status.dart';

export 'peer_status.dart';

class Peer extends NativeDto {
  late final String deviceName;
  late final String deviceAddress;
  late final PeerStatus status;

  Peer.fromMap(super.map) : super.fromMap() {
    deviceName = all['deviceName'] as String;
    deviceAddress = all['deviceAddress'] as String;
    status = PeerStatus.fromId(all['status'] as num);
  }

  // Peer.fromJson(super.json) : super.fromJson() {
  //   deviceName = all['deviceName'] as String;
  //   deviceAddress = all['deviceAddress'] as String;
  //   status = PeerStatus.fromId(all['status'] as int);
  // }
}
