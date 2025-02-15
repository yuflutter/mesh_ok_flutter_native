import 'native_dto.dart';
import 'peer_status.dart';

export 'peer_status.dart';

class Peer extends NativeDto {
  final String deviceName;
  final PeerStatus status;

  Peer.fromDto(Map<Object?, Object?> dto)
      : deviceName = dto['deviceName'] as String,
        status = PeerStatus.fromId(dto['status'] as num),
        super.fromDto(dto);
}
