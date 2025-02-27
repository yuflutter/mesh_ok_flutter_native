import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/entity/wifi_p2p_device.dart';
import '/entity/text_message.dart';
import '/data/chat_repository.dart';
import 'socket_chat_state.dart';

class SocketChatCubitStub extends Cubit<SocketChatState> {
  final WifiP2pDevice myDevice;
  final _chatRepository = global<AbstractChatRepository>();

  SocketChatCubitStub({required this.myDevice}) : super(SocketChatState.initial());

  @mustBeOverridden
  Future<void> init() async {
    emit(state.copyWith(messages: _chatRepository.messages));
  }

  @mustBeOverridden
  void sendMessage(String text) => throw 'impossible to send a message';

  void addMessage(TextMessage m) {
    emit(state.copyWith(messages: _chatRepository.addMessage(m)));
  }

  void clearMessages() {
    emit(state.copyWith(messages: _chatRepository.clear()));
  }
}
