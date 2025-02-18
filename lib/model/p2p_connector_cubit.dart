import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_ok/entity/socket_status.dart';
import 'package:mesh_ok/model/socket_cubit.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/peer.dart';
import '/entity/wifi_p2p_info.dart';
import '/data/p2p_info_repository.dart';
import 'etc/dowl.dart';
import 'p2p_connector_state.dart';
import 'platform.dart';

class P2pConnectorCubit extends Cubit<P2pConnectorState> with WidgetsBindingObserver {
  final P2pInfoRepository repository;

  late final Platform _platform;

  P2pConnectorCubit({required this.repository}) : super(P2pConnectorState.initial()) {
    _platform = Platform(onPeersDiscovered: _onPeersDiscovered, onP2pInfoChanged: _onP2pInfoChanged);
  }

  Future<void> init() async {
    final log = global<Logger>();
    try {
      // Нет способа получить из сети текущее состояние p2p, поэтому сохраняем его локально,
      // и восстанавливаем при старте приложения.
      await repository.init();
      // emit(state.copyWith(p2pInfo: repository.restoreP2pInfo()));

      await dowl('init()', _platform.init);

      await refreshAll();

      // if (state.p2pInfo?.isConnected == true) {
      //   tryToOpenSocket();
      // }

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

  void _onPeersDiscovered(List result) {
    final log = global<Logger>();
    try {
      log.i(result);
      final peers = result.map((e) => Peer.fromJson(e as String)).toList();
      log.i('peers: ${peers.length}');
      emit(state.copyWith(peers: peers));
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> _getGroupInfo() async {
    // final groupInfo = await _conn.groupInfo();
    // global<Logger>().info('groupInfo() => ${groupInfo?.toJson()}');
    // emit(state.copyWith(p2pGroupInfo: groupInfo));
  }

  Future<void> connectPeer(Peer peer) async {
    await dowl('connectPeer(${peer.deviceName})', () => _platform.connectPeer(peer.deviceAddress));
  }

  void _onP2pInfoChanged(String result) async {
    final log = global<Logger>();
    try {
      log.i(result);
      final p2pInfo = WifiP2PInfo.fromJson(result);
      emit(state.copyWith(p2pInfo: p2pInfo));
      if (state.p2pInfo?.isConnected == true) {
        tryToOpenSocket();
      }
      // await repository.saveP2pInfo(p2pInfo); // сохраняем для следующего запуска
      // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> disconnectMe() async {
    await dowl('disconnectMe()', _platform.disconnectMe);
  }

  Future<void> removeGroup() async {
    // await dowl('removeGroup()', _conn.removeGroup);
    // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  void tryToOpenSocket() async {
    if (state.p2pInfo?.isConnected != true) return;
    final socketCubit = SocketCubit(p2pInfo: state.p2pInfo!);
    socketCubit
      ..init()
      ..socketStatusStream.listen((socketStatus) {
        emit(
          state.copyWith(
            socketStatus: socketStatus,
            justConnectedSocket: (socketStatus == SocketStatus.connected) ? socketCubit : null,
          ),
        );
      });
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
