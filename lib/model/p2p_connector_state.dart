import '/entity/peer.dart';
import '../entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';

class P2pConnectorState {
  final List<Peer> peers;
  final WifiP2PInfo? p2pInfo;
  // final WifiP2PGroupInfo? p2pGroupInfo;
  final SocketStatus socketStatus;
  // final SocketCubit? justConnectedSocket; // одноразовый сигнал установки нового соединения
  final String? userErrorMsg;

  P2pConnectorState._({
    this.peers = const [],
    this.p2pInfo,
    // this.p2pGroupInfo,
    this.socketStatus = SocketStatus.notConnected,
    // this.justConnectedSocket,
    this.userErrorMsg,
  });

  factory P2pConnectorState.initial() => P2pConnectorState._();

  P2pConnectorState copyWith({
    final List<Peer>? peers,
    final WifiP2PInfo? p2pInfo,
    // final WifiP2PGroupInfo? p2pGroupInfo,
    final SocketStatus? socketStatus,
    // final SocketCubit? justConnectedSocket,
    final String? userErrorMsg,
  }) => P2pConnectorState._(
    peers: peers ?? this.peers,
    p2pInfo: p2pInfo ?? this.p2pInfo,
    // p2pGroupInfo: p2pGroupInfo ?? this.p2pGroupInfo,
    socketStatus: socketStatus ?? this.socketStatus,
    // justConnectedSocket: justConnectedSocket ?? null, // сбрасываем одноразовый сигнал
    userErrorMsg: userErrorMsg ?? this.userErrorMsg,
  );

  bool get isError => (userErrorMsg != null);
}
