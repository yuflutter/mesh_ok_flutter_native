import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/peer.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';
import '/data/p2p_info_repository.dart';
import 'etc/dowl.dart';
import 'p2p_connector_state.dart';
import 'platform.dart';
import 'socket_chat_cubit.dart';

class P2pConnectorCubit extends Cubit<P2pConnectorState> with WidgetsBindingObserver {
  final P2pInfoRepository repository;

  late final Platform _platform;
  SocketChatCubit? _socketChatCubit;
  StreamSubscription? _socketChatStateSubscription;

  P2pConnectorCubit({required this.repository}) : super(P2pConnectorState.initial()) {
    _platform = Platform(
      onPeersDiscovered: _onPeersDiscovered,
      onP2pInfoChanged: _onP2pInfoChanged,
    );
  }

  Future<void> init() async {
    final log = global<Logger>();
    try {
      // await repository.init();
      await dowl('init()', _platform.init);
      await refreshAll();
      WidgetsBinding.instance.addObserver(this);
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([_discoverPeers(), _getGroupInfo()]);
  }

  Future<void> _discoverPeers() async {
    await dowl('discoverPeers()', _platform.discoverPeers);
  }

  void _onPeersDiscovered(List peersJson) {
    final log = global<Logger>();
    try {
      log.i('peers(${peersJson.length}): $peersJson');
      final peers = peersJson.map((e) => Peer.fromJson(e)).toList();
      emit(state.copyWith(peers: peers));
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> connectPeer(Peer peer) async {
    await dowl('connectPeer(${peer.deviceName})', () => _platform.connectPeer(peer.deviceAddress));
  }

  void _onP2pInfoChanged(String p2pInfoJson) async {
    final log = global<Logger>();
    try {
      log.i('P2PInfo: $p2pInfoJson');
      final p2pInfo = WifiP2PInfo.fromJson(p2pInfoJson);
      emit(state.copyWith(p2pInfo: p2pInfo));
      if (state.p2pInfo?.isConnected == true) {
        tryToOpenSocketChat();
      }
      // await repository.saveP2pInfo(p2pInfo); // сохраняем для следующего запуска
      // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  void tryToOpenSocketChat() async {
    if (state.p2pInfo?.isConnected != true) return;
    final log = global<Logger>();
    try {
      await _socketChatStateSubscription?.cancel();
      await _socketChatCubit?.close();

      _socketChatCubit = SocketChatCubit(p2pInfo: state.p2pInfo!);
      SocketStatus? oldSocketStatus;

      _socketChatStateSubscription = _socketChatCubit!.stream.listen((socketChatState) {
        final socketStatus = socketChatState.socketStatus;
        final doOpenChat = (socketStatus != oldSocketStatus && socketStatus == SocketStatus.connected);
        oldSocketStatus = socketStatus;
        emit(
          state.copyWith(
            socketStatus: socketStatus,
            doOpenSocketChat: (doOpenChat) ? _socketChatCubit : null,
          ),
        );
        if (socketStatus == SocketStatus.closed) {
          _socketChatStateSubscription?.cancel();
          _socketChatCubit == null;
        }
      });

      _socketChatCubit!.init();
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> disconnectMe() async {
    await dowl('disconnectMe()', _platform.disconnectMe);
  }

  Future<void> _getGroupInfo() async {
    // final groupInfo = await _conn.groupInfo();
    // global<Logger>().info('groupInfo() => ${groupInfo?.toJson()}');
    // emit(state.copyWith(p2pGroupInfo: groupInfo));
  }

  Future<void> removeGroup() async {
    // await dowl('removeGroup()', _conn.removeGroup);
    // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final log = global<Logger>();
    log.i(state);
    // if (state == AppLifecycleState.paused) {
    //   // await dowl('unregister()', _conn.unregister);
    // } else if (state == AppLifecycleState.resumed) {
    //   await dowl('register()', _conn.register);
    //   await refreshAll();
    // }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _platform.close();
    return super.close();
  }
}
