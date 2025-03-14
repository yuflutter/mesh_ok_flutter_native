import '/entity/wifi_p2p_device.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/device_role.dart';
import '/entity/wifi_p2p_group.dart';
import 'socket_chat_cubit_stub.dart';

class P2pConnectorState {
  final WifiP2pDevice? myDevice;
  final List<WifiP2pDevice> peers;
  final WifiP2PInfo? p2pInfo;
  final WifiP2PGroup? p2pGroup;
  final SocketChatCubitStub? socketChatCubit;

  DeviceRole get deviceRole => p2pInfo?.deviceRole ?? DeviceRole.notConnected;

  P2pConnectorState._({
    this.myDevice,
    this.peers = const [],
    this.p2pInfo,
    this.p2pGroup,
    this.socketChatCubit,
  });

  factory P2pConnectorState.initial() => P2pConnectorState._();

  P2pConnectorState copyWith({
    final WifiP2pDevice? myDevice,
    final List<WifiP2pDevice>? peers,
    final WifiP2PInfo? p2pInfo,
    final WifiP2PGroup? p2pGroup,
    final SocketChatCubitStub? socketChatCubit,
  }) =>
      P2pConnectorState._(
        myDevice: myDevice ?? this.myDevice,
        peers: peers ?? this.peers,
        p2pInfo: p2pInfo ?? this.p2pInfo,
        p2pGroup: p2pGroup ?? this.p2pGroup,
        socketChatCubit: socketChatCubit ?? this.socketChatCubit,
      );
}
