import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';
import '/entity/text_message.dart';
import 'etc/dowl.dart';
import 'socket_chat_state.dart';

const _port = 4045;

class SocketChatCubit extends Cubit<SocketChatState> {
  final WifiP2PInfo p2pInfo;

  WebSocket? _socket;
  StreamSubscription? _socketSubscription;
  HttpServer? _httpServer;
  StreamSubscription? _httpServerSubscription;

  SocketChatCubit({required this.p2pInfo}) : super(SocketChatState.initial());

  Future<void> init() => switch (p2pInfo.deviceRole) {
        DeviceRole.client => _initClient(),
        DeviceRole.host => _initHost(),
      };

  Future<void> _initClient() async {
    final log = global<Logger>();
    try {
      // TODO: Узнать, как вытащить (изменить?) сетевое имя меня, и подставить сюда:
      final url = 'ws://${p2pInfo.groupOwnerAddress}:$_port/ws?as=';
      log.i('connecting to $url ...');
      emit(state.copyWith(socketStatus: SocketStatus.connectingToHost));

      _socket = await WebSocket.connect(url);
      log.i('connected');
      emit(state.copyWith(socketStatus: SocketStatus.connected));

      _listenForMessages();
    } catch (e, s) {
      log.e(this, e, s);
      close();
    }
  }

  Future<void> _initHost() async {
    final log = global<Logger>();
    try {
      _httpServer = await HttpServer.bind(p2pInfo.groupOwnerAddress, _port, shared: true);
      log.i("waiting for incoming...");
      emit(state.copyWith(socketStatus: SocketStatus.waitingIncoming));

      _httpServerSubscription = _httpServer!.listen(
        (req) async {
          // TODO: Входящих соединений может быть много, разобраться с группой p2p
          if (req.uri.path == '/ws') {
            _socket = await WebSocketTransformer.upgrade(req);
            log.i('connection received from address ${req.connectionInfo?.remoteAddress}');
            emit(state.copyWith(socketStatus: SocketStatus.connected));
            _listenForMessages();
          }
        },
        onError: (e, s) {
          log.e(this, e, s);
          close();
        },
        onDone: () {
          log.i('server socket closed');
          close();
        },
      );
    } catch (e, s) {
      log.e(this, e, s);
    }
  }

  void sendMessage(String msg) {
    try {
      if (_socket == null) throw 'socket allready closed';
      dowl('sendMessage()', () {
        _socket!.add(msg);
        return msg;
      });
      emit(state.copyWith()..messages.add(TextMessage(msg, isMy: true)));
    } catch (e, s) {
      global<Logger>().e(this, e, s);
    }
  }

  void _listenForMessages() {
    final log = global<Logger>();
    _socketSubscription = _socket!.listen(
      (msg) async {
        log.i('received message: "$msg"');
        emit(state.copyWith()..messages.add(TextMessage(msg)));
      },
      onError: (e, s) {
        log.e(this, e, s);
        close();
      },
      onDone: () {
        log.i('socket closed by peer');
        close();
      },
    );
  }

  @override
  Future<void> close() async {
    try {
      // срабатывает, если close() вызвали принудительно, иначе ошибка
      emit(state.copyWith(socketStatus: SocketStatus.closed));
    } catch (_) {}
    await _socketSubscription?.cancel();
    await _socket?.close();
    _socket = null;
    await _httpServerSubscription?.cancel();
    await _httpServer?.close();
    return super.close();
  }
}
