import '/entity/text_message.dart';

class SocketState {
  final List<TextMessage> messages;
  Object? error;

  SocketState._({
    required this.messages,
    this.error,
  });

  factory SocketState.initial() => SocketState._(messages: []);

  SocketState copyWith({
    final Object? error,
  }) =>
      SocketState._(
        // Для добавления элементов используем внутреннюю мутабельность стейта
        messages: messages,
        error: error ?? this.error,
      );
}
