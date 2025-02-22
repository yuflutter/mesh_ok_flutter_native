import '/entity/wifi_p2p_device.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';
import '/entity/device_role.dart';
import 'socket_chat_cubit.dart';

class P2pConnectorState {
  final WifiP2pDevice? me;
  final List<WifiP2pDevice> peers;
  final WifiP2PInfo? p2pInfo;
  // final WifiP2PGroupInfo? p2pGroupInfo;
  final SocketStatus socketStatus;
  // одноразовый сигнал успешной установки соединения:
  final SocketChatCubit? doOpenSocketChat;
  // final String? userErrorMsg;

  DeviceRole get deviceRole => p2pInfo?.deviceRole ?? DeviceRole.notConnected;

  P2pConnectorState._({
    this.me,
    this.peers = const [],
    this.p2pInfo,
    // this.p2pGroupInfo,
    this.socketStatus = SocketStatus.notConnected,
    this.doOpenSocketChat,
    // this.userErrorMsg,
  });

  factory P2pConnectorState.initial() => P2pConnectorState._();

  P2pConnectorState copyWith({
    final WifiP2pDevice? me,
    final List<WifiP2pDevice>? peers,
    final WifiP2PInfo? p2pInfo,
    // final WifiP2PGroupInfo? p2pGroupInfo,
    final SocketStatus? socketStatus,
    final SocketChatCubit? doOpenSocketChat,
    // final String? userErrorMsg,
  }) =>
      P2pConnectorState._(
        me: me ?? this.me,
        peers: peers ?? this.peers,
        p2pInfo: p2pInfo ?? this.p2pInfo,
        // p2pGroupInfo: p2pGroupInfo ?? this.p2pGroupInfo,
        socketStatus: socketStatus ?? this.socketStatus,
        // сбрасываем одноразовый сигнал при следующем копировании:
        doOpenSocketChat: doOpenSocketChat ?? null,
        // userErrorMsg: userErrorMsg ?? this.userErrorMsg,
      );

  // bool get isError => (userErrorMsg != null);
}
