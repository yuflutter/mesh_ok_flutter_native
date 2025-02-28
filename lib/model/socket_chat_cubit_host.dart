import 'dart:io';
import 'dart:async';

import '/app_config.dart';
import '/core/global.dart';
import '/core/logger.dart';
import '/entity/socket_status.dart';
import '/entity/text_message.dart';
import '/entity/wifi_p2p_info.dart';
import 'socket_chat_cubit_stub.dart';
import 'socket_client_session.dart';

class SocketChatCubitHost extends SocketChatCubitStub {
  final WifiP2PInfo p2pInfo;
  HttpServer? _httpServer;
  StreamSubscription? _httpServerSubscription;
  final List<SocketClientSession> _clientSessions = [];

  SocketChatCubitHost({required super.myDevice, required this.p2pInfo});

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

              final clientSession = SocketClientSession(
                socket: socket,
                onMessageReceived: (m) {
                  addMessage(m);
                  _spreadMessage(m, exceptAuthor: socket);
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
              _clientSessions.add(clientSession);
              emit(state.copyWith(socketStatus: SocketStatusConnectedAsHost(_clientSessions.length)));
              clientSession.sendMessage(TextMessage(from: myDevice.deviceName, text: 'connected'));
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
    final msg = TextMessage(from: myDevice.deviceName, text: text);
    final clients = List<SocketClientSession>.from(_clientSessions);
    final errors = [];
    for (final c in clients) {
      try {
        c.sendMessage(msg);
      } catch (e) {
        errors.add(e);
      }
    }
    if (errors.length == clients.length) {
      throw errors.join('\n');
    } else {
      addMessage(msg);
    }
  }

  void _spreadMessage(TextMessage msg, {required WebSocket exceptAuthor}) {
    for (final c in List<SocketClientSession>.from(_clientSessions)) {
      if (c.socket != exceptAuthor) {
        c.sendMessage(msg);
      }
    }
  }

  @override
  Future<void> close() {
    for (final c in List<SocketClientSession>.from(_clientSessions)) {
      c.close();
    }
    _httpServerSubscription?.cancel();
    _httpServer?.close();
    return super.close();
  }
}
