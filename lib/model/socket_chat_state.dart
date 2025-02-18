import '/entity/socket_status.dart';
import '/entity/text_message.dart';

class SocketChatState {
  final SocketStatus socketStatus;
  final List<TextMessage> messages;
  Object? error;

  SocketChatState._({required this.socketStatus, required this.messages, this.error});

  factory SocketChatState.initial() => SocketChatState._(
        socketStatus: SocketStatus.notConnected,
        messages: [],
      );

  SocketChatState copyWith({
    final SocketStatus? socketStatus,
    final Object? error,
  }) =>
      SocketChatState._(
        socketStatus: socketStatus ?? this.socketStatus,
        // Для добавления сообщений используем внутреннюю мутабельность стейта
        messages: messages,
        error: error ?? this.error,
      );
}
