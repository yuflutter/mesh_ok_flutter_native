import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/wifi_p2p_device.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/device_role.dart';
import 'etc/dowl.dart';
import 'platform.dart';
import 'p2p_connector_state.dart';
import 'socket_chat_cubit_stub.dart';
import 'socket_chat_cubit_client.dart';
import 'socket_chat_cubit_host.dart';

class P2pConnectorCubit extends Cubit<P2pConnectorState> with WidgetsBindingObserver {
  late final Platform _platform;

  SocketChatCubitStub? _socketChatCubit;
  StreamSubscription? _chatStateSubscription;

  P2pConnectorCubit() : super(P2pConnectorState.initial()) {
    _platform = Platform(
      onPeersDiscovered: _onPeersDiscovered,
      onP2pInfoChanged: _onP2pInfoChanged,
    );
  }

  Future<void> init() async {
    try {
      emit(state.copyWith(myDevice: await _platform.init()));
      await refreshAll();
      WidgetsBinding.instance.addObserver(this);
    } catch (e, s) {
      global<Logger>().e(this, e, s);
    }
  }

  Future<void> refreshAll() async {
    try {
      await Future.wait([
        _platform.requestConnectionInfo(),
        _platform.discoverPeers(),
        // _getGroupInfo(),
      ]);
    } catch (e, s) {
      global<Logger>().e(this, e, s);
    }
  }

  void _onPeersDiscovered(List peersJson) {
    final log = global<Logger>();
    try {
      log.i('peers(${peersJson.length}): $peersJson');
      final peers = peersJson.map((e) => WifiP2pDevice.fromJson(e)).toList();
      emit(state.copyWith(peers: peers));
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> connectPeer(WifiP2pDevice peer) => _platform.connectPeer(peer);

  void _onP2pInfoChanged(String p2pInfoJson) async {
    final log = global<Logger>();
    try {
      await _chatStateSubscription?.cancel();
      await _socketChatCubit?.close();

      log.i('P2PInfo: $p2pInfoJson');
      final p2pInfo = WifiP2PInfo.fromJson(p2pInfoJson);

      _socketChatCubit = switch (p2pInfo.deviceRole) {
        DeviceRole.client => SocketChatCubitClient(myDevice: state.myDevice!, p2pInfo: p2pInfo),
        DeviceRole.host => SocketChatCubitHost(myDevice: state.myDevice!, p2pInfo: p2pInfo),
        _ => SocketChatCubitStub(myDevice: state.myDevice!),
      }
        ..init();
      log.i('created $_socketChatCubit');
      emit(state.copyWith(p2pInfo: p2pInfo, socketChatCubit: _socketChatCubit));

      // SocketStatus? oldSocketStatus;
      // _chatStateSubscription = _socketChatCubit!.stream.listen(
      //   (chatState) {
      //     // тут может быть какая-то логика смены статуса сокета, но ее нет, да и плохо размещать её в коннекторе
      //     oldSocketStatus = chatState.socketStatus;
      //     emit(state.copyWith(socketChatCubit: _socketChatCubit));
      //   },
      // );
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  Future<void> disconnectMe() async {
    await dowl('disconnectMe()', _platform.disconnectMe);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final log = global<Logger>();
    log.i(state);
    if (state == AppLifecycleState.resumed) {
      refreshAll();
    }
    // смотри котлин, там тоже есть такой обработчик
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _chatStateSubscription?.cancel();
    _socketChatCubit?.close();
    _platform.close();
    return super.close();
  }
}
