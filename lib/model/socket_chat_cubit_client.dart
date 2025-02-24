import 'dart:io';
import 'dart:async';

import '/app_config.dart';
import '/core/global.dart';
import '/core/logger.dart';
import '/entity/socket_status.dart';
import '/entity/text_message.dart';
import 'socket_chat_cubit_abstract.dart';
import 'socket_client_session.dart';

class SocketChatCubitClient extends SocketChatCubitAbstract {
  SocketClientSession? _clientSession;

  SocketChatCubitClient({required super.me, required super.p2pInfo});

  @override
  Future<void> init() async {
    final log = global<Logger>();
    final port = global<AppConfig>().websocketPort;

    final url = 'ws://${p2pInfo.groupOwnerAddress}:$port/ws?me=${me.deviceName}';
    log.i('connecting to $url ...');
    emit(state.copyWith(socketStatus: SocketStatusConnectingToHost()));

    WebSocket? socket;
    while (!isClosed) {
      try {
        socket = await WebSocket.connect(url);
        log.i('connected');
        emit(state.copyWith(socketStatus: SocketStatusConnectedAsClient()));

        _clientSession = SocketClientSession(
          socket: socket,
          onMessageSent: (m) => addMessage(m),
          onMessageReceived: (m) {
            addMessage(m);
            emit(state.copyWith(doOpenChat: true));
          },
          onSocketError: (e) {
            _clientSession = null;
            emit(state.copyWith(socketStatus: SocketStatusClosed()));
            init();
          },
        );
        sendMessage('сonnected');
        break;
      } catch (e) {
        log.w(e);
        emit(state.copyWith(
          socketStatus: (state.socketStatus as SocketStatusConnectingToHost) + 1,
        ));
      }
      await Future.delayed(global<AppConfig>().tryToConnectToHostIn);
    }
    return super.init();
  }

  @override
  void sendMessage(String text) {
    if (_clientSession != null && state.socketStatus is SocketStatusConnectedAsClient) {
      _clientSession!.sendMessage(TextMessage(from: me.deviceName, text: text));
    } else {
      throw 'no connection to host';
    }
  }

  @override
  Future<void> close() {
    _clientSession?.close();
    return super.close();
  }
}
