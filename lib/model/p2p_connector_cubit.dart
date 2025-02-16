import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/peer.dart';
import '/data/p2p_info_repository.dart';
import 'p2p_connector_state.dart';
import 'etc/dowl.dart';

const _androidChannelName = "WifiP2pMethodChannel";

class P2pConnectorCubit extends Cubit<P2pConnectorState> with WidgetsBindingObserver {
  final P2pInfoRepository repository;

  final _androidChannel = MethodChannel(_androidChannelName);

  // StreamSubscription? _eventSubscription;

  P2pConnectorCubit({required this.repository}) : super(P2pConnectorState.initial());

  Future<void> init() async {
    final logger = global<Logger>();
    try {
      // Нет способа получить из сети текущее состояние p2p, поэтому сохраняем его локально,
      // и восстанавливаем при старте приложения.
      await repository.init();
      // emit(state.copyWith(p2pInfo: repository.restoreP2pInfo()));

      await _androidChannel.invokeMethod('init');

      _androidChannel.setMethodCallHandler((call) async {
        // logger.info('Received event: $call');
        return switch (call.method) {
          'onPeersDiscovered' => _onPeersDiscovered(call.arguments),
          _ => throw 'unknown method received: ${call.method}',
        };
      });

      await refreshAll();

      // if (state.p2pInfo?.isConnected == true) {
      //   tryToOpenSocket();
      // }

      WidgetsBinding.instance.addObserver(this);
    } catch (e, s) {
      logger.error('$runtimeType', e, s);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([_discoverPeers(), _getGroupInfo()]);
  }

  Future<void> _discoverPeers() async {
    await dowl('discoverPeers()', () => _androidChannel.invokeMethod('discoverPeers'));
  }

  void _onPeersDiscovered(dynamic result) {
    final logger = global<Logger>();
    try {
      logger.info(result);
      final peers = (result as List).map((e) => Peer.fromDto(e)).toList();
      logger.info('peers: ${peers.length}');
      emit(state.copyWith(peers: peers));
    } catch (e, s) {
      logger.error('$runtimeType', e, s);
    }
  }

  Future<void> _getGroupInfo() async {
    // final groupInfo = await _conn.groupInfo();
    // global<Logger>().info('groupInfo() => ${groupInfo?.toJson()}');
    // emit(state.copyWith(p2pGroupInfo: groupInfo));
  }

  Future<void> connectPeer(Peer peer) async {
    final res = await dowl(
      'connectPeer(${peer.deviceName})',
      () => _androidChannel.invokeMethod('connectPeer', peer.deviceAddress),
    );

    // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  Future<void> disconnectFromGroup() async {
    // await dowl('disconnect()', _conn.disconnect);
    // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  Future<void> removeGroup() async {
    // await dowl('removeGroup()', _conn.removeGroup);
    // _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  // void _onP2pInfoChanged(WifiP2PInfo p2pInfo) async {
  //   final logger = global<Logger>();
  //   try {
  //     logger.info(p2pInfo.toJson());
  //     emit(state.copyWith(p2pInfo: p2pInfo));

  //     if (state.p2pInfo?.isConnected == true) {
  //       tryToOpenSocket();
  //     }

  //     await repository.saveP2pInfo(p2pInfo); // сохраняем для следующего запуска
  //     _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  //   } catch (e, s) {
  //     logger.error('$runtimeType', e, s);
  //   }
  // }

  // void tryToOpenSocket() async {
  //   if (state.p2pInfo?.isConnected != true) return;
  //   _conn.closeSocket(notify: false);
  //   final socketCubit = SocketCubit(p2pInfo: state.p2pInfo!);
  //   socketCubit
  //     ..init()
  //     ..socketStatusStream.listen((socketStatus) {
  //       emit(state.copyWith(
  //         socketStatus: socketStatus,
  //         justConnectedSocket: (socketStatus == SocketStatus.connected) ? socketCubit : null,
  //       ));
  //     });
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final logger = global<Logger>();
    logger.info(state);
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
    _androidChannel.setMethodCallHandler(null);
    return super.close();
  }
}
