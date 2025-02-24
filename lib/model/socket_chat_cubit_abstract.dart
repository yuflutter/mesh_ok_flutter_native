import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/wifi_p2p_device.dart';
import '/entity/text_message.dart';
import '/data/chat_repository.dart';
import 'socket_chat_state.dart';

abstract class SocketChatCubitAbstract extends Cubit<SocketChatState> {
  final WifiP2pDevice me;
  final WifiP2PInfo p2pInfo;
  final _chatRepository = global<AbstractChatRepository>();

  SocketChatCubitAbstract({required this.me, required this.p2pInfo}) : super(SocketChatState.initial());

  @mustBeOverridden
  Future<void> init() async {
    emit(state.copyWith(messages: _chatRepository.messages));
  }

  void sendMessage(String text);

  void addMessage(TextMessage m) {
    emit(state.copyWith(messages: _chatRepository.addMessage(m)));
  }

  void clearMessages() {
    emit(state.copyWith(messages: _chatRepository.clear()));
  }
}
