import '/entity/socket_status.dart';
import '/entity/text_message.dart';

class SocketChatState {
  final SocketStatus socketStatus;
  final List<TextMessage> messages;
  // одноразовый сигнал чтобы открыть чат:
  final bool doOpenChat;

  SocketChatState._({
    this.socketStatus = const SocketStatusNotConnected(),
    this.messages = const [],
    this.doOpenChat = false,
  });

  factory SocketChatState.initial() => SocketChatState._();

  SocketChatState copyWith({
    final SocketStatus? socketStatus,
    final List<TextMessage>? messages,
    final bool? doOpenChat,
  }) =>
      SocketChatState._(
        socketStatus: socketStatus ?? this.socketStatus,
        messages: messages ?? this.messages,
        // сбрасываем одноразовый сигнал при следующем копировании:
        doOpenChat: doOpenChat ?? false,
      );
}
