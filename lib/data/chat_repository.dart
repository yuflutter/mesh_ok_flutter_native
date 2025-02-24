import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '/app_config.dart';
import '/core/global.dart';
import '/entity/text_message.dart';

abstract class AbstractChatRepository {
  List<TextMessage> get messages;
  Future<void> init();
  List<TextMessage> addMessage(TextMessage msg);
  List<TextMessage> clear();
}

class SimpleDumbChatRepository implements AbstractChatRepository {
  late final SharedPreferences _db;
  late final List<TextMessage> _messages;

  @override
  get messages => List.unmodifiable(_messages);

  @override
  Future<void> init() async {
    _db = await SharedPreferences.getInstance();

    _messages = _db.getStringList('$runtimeType')?.map((e) => TextMessage.fromJson(e)).toList() ?? [];

    Timer.periodic(global<AppConfig>().saveMessagesEvery, (_) {
      _db.setStringList('$runtimeType', _messages.map((e) => e.toJson()).toList());
    });
  }

  @override
  List<TextMessage> addMessage(TextMessage msg) {
    _messages.add(msg);
    return messages;
  }

  @override
  List<TextMessage> clear() {
    _messages.clear();
    return messages;
  }
}
