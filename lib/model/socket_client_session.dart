import 'dart:async';
import 'dart:io';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/text_message.dart';

class SocketClientSession {
  final WebSocket socket;
  void Function(TextMessage) onMessageSent;
  void Function(TextMessage) onMessageReceived;
  void Function(dynamic error) onSocketError;

  StreamSubscription? _socketSubscription;

  SocketClientSession({
    required this.socket,
    required this.onMessageSent,
    required this.onMessageReceived,
    required this.onSocketError,
  }) {
    _listenForMessages();
  }

  void sendMessage(TextMessage msg) {
    try {
      if (socket.readyState != 1) {
        throw 'can\'t send a message, socket is ${_socketReadyState(socket.readyState)}';
      } else {
        socket.add(msg.toJson());
        onMessageSent(msg);
      }
    } catch (e, s) {
      global<Logger>().e(this, e, s);
      close();
      onSocketError(e);
      rethrow;
    }
  }

  void _listenForMessages() {
    final log = global<Logger>();
    _socketSubscription = socket.listen((json) async {
      log.i('received message: "$json"');
      try {
        onMessageReceived(TextMessage.fromJson(json));
      } catch (e, s) {
        log.e(this, e, s);
        close();
        onSocketError(e);
      }
    }, onError: (e, s) {
      log.e(this, e, s);
      close();
      onSocketError(e);
    }, onDone: () {
      final e = 'socket closed by peer';
      log.w(e);
      close();
      onSocketError(e);
    });
  }

  String _socketReadyState(int readyState) => switch (readyState) {
        0 => 'connecting',
        1 => 'open',
        2 => 'closing',
        3 => 'closed',
        _ => '$readyState',
      };

  void close() {
    _socketSubscription?.cancel();
    socket.close();
  }
}
