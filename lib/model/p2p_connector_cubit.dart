import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/wifi_p2p_device.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';
import '/entity/device_role.dart';
import 'etc/dowl.dart';
import 'platform.dart';
import 'p2p_connector_state.dart';
import 'socket_chat_cubit_abstract.dart';
import 'socket_chat_cubit_client.dart';
import 'socket_chat_cubit_host.dart';

class P2pConnectorCubit extends Cubit<P2pConnectorState> with WidgetsBindingObserver {
  late final Platform _platform;

  SocketChatCubitAbstract? _socketChatCubit;
  StreamSubscription? _chatStateSubscription;

  P2pConnectorCubit() : super(P2pConnectorState.initial()) {
    _platform = Platform(
      onPeersDiscovered: _onPeersDiscovered,
      onP2pInfoChanged: _onP2pInfoChanged,
    );
  }

  Future<void> init() async {
    try {
      emit(state.copyWith(me: await _platform.init()));
      await refreshAll();
      WidgetsBinding.instance.addObserver(this);
    } catch (e, s) {
      global<Logger>().e(this, e, s);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      _platform.requestConnectionInfo(),
      _platform.discoverPeers(),
      // _getGroupInfo(),
    ]);
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
      log.i('P2PInfo: $p2pInfoJson');
      final p2pInfo = WifiP2PInfo.fromJson(p2pInfoJson);
      emit(state.copyWith(p2pInfo: p2pInfo));
      if (state.p2pInfo?.isConnected == true) {
        await _chatStateSubscription?.cancel();
        await _socketChatCubit?.close();

        _socketChatCubit = switch (state.deviceRole) {
          DeviceRole.client => SocketChatCubitClient(me: state.me!, p2pInfo: state.p2pInfo!),
          DeviceRole.host => SocketChatCubitHost(me: state.me!, p2pInfo: state.p2pInfo!),
          _ => throw 'device is not connectet, bld!',
        };

        SocketStatus? oldSocketStatus;
        _chatStateSubscription = _socketChatCubit!.stream.listen(
          (chatState) {
            final socketStatus = chatState.socketStatus;
            // тут может быть какая-то логика смены статуса сокета, но ее пока нет
            oldSocketStatus = socketStatus;
            // тут будут срабатывать все геттеры p2p-стейта, отражающие изменение сокет-стейта
            emit(state.copyWith(socketChatCubit: _socketChatCubit));
          },
        );

        _socketChatCubit!.init();
      } else {
        _chatStateSubscription?.cancel();
        _socketChatCubit?.close();
        _socketChatCubit = null;
      }
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  // void doOpenChat() {
  //   if (_socketChatCubit?.state.socketStatus is SocketStatusConnected) {
  //     emit(state.copyWith(doOpenChat: true));
  //   } else {
  //     global<Logger>().w('socket is not connected');
  //   }
  // }

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
