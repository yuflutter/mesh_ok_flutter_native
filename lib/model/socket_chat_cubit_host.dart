import 'dart:io';
import 'dart:async';

import '/app_config.dart';
import '/core/global.dart';
import '/core/logger.dart';
import '/entity/socket_status.dart';
import '/entity/text_message.dart';
import 'socket_chat_cubit_abstract.dart';
import 'socket_client_session.dart';

class SocketChatCubitHost extends SocketChatCubitAbstract {
  HttpServer? _httpServer;
  StreamSubscription? _httpServerSubscription;
  final List<SocketClientSession> _clientSessions = [];

  SocketChatCubitHost({required super.me, required super.p2pInfo});

  @override
  Future<void> init() async {
    final log = global<Logger>();
    final port = global<AppConfig>().websocketPort;
    try {
      _httpServer = await HttpServer.bind(p2pInfo.groupOwnerAddress, port, shared: true);
      log.i("waiting for incoming...");
      emit(state.copyWith(socketStatus: SocketStatusWaitingIncoming()));

      _httpServerSubscription = _httpServer!.listen(
        (req) async {
          try {
            if (req.uri.path == '/ws') {
              final socket = await WebSocketTransformer.upgrade(req);
              log.i('connection received from address ${req.connectionInfo?.remoteAddress}');

              final client = SocketClientSession(
                socket: socket,
                onMessageSent: (m) => addMessage(m),
                onMessageReceived: (m) {
                  addMessage(m);
                  _spreadMessage(m, exceptMe: socket);
                  emit(state.copyWith(doOpenChat: true));
                },
                onSocketError: (e) {
                  _clientSessions.removeWhere((c) => c.socket == socket);
                  emit(state.copyWith(
                    socketStatus: (_clientSessions.isEmpty)
                        ? SocketStatusWaitingIncoming()
                        : SocketStatusConnectedAsHost(_clientSessions.length),
                  ));
                },
              );

              _clientSessions.add(client);
              emit(state.copyWith(socketStatus: SocketStatusConnectedAsHost(_clientSessions.length)));
              sendMessage('сonnected');
            }
          } catch (e, s) {
            log.e(this, e, s);
          }
        },
        onError: (e, s) {
          log.e(this, e, s);
        },
        onDone: () {
          log.w('server socket closed');
        },
      );
    } catch (e, s) {
      log.e(this, e, s);
    }
    return super.init();
  }

  @override
  void sendMessage(String text) {
    if (_clientSessions.isEmpty) throw 'no clients connected';
    var err = '';
    for (final c in List.from(_clientSessions)) {
      try {
        c.sendMessage(TextMessage(from: me.deviceName, text: text));
      } catch (e) {
        err += '$e\n';
      }
    }
    err = err.trim();
    if (err.isNotEmpty) throw err;
  }

  void _spreadMessage(TextMessage msg, {required WebSocket exceptMe}) {
    for (final c in List.from(_clientSessions)) {
      if (c.socket != exceptMe) {
        c.sendMessage(msg);
      }
    }
  }

  @override
  Future<void> close() {
    for (final c in List.from(_clientSessions)) {
      c.close();
    }
    _httpServerSubscription?.cancel();
    _httpServer?.close();
    return super.close();
  }
}
