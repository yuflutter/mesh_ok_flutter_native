import 'dart:convert';

class TextMessage {
  final String? from;
  final String text;

  TextMessage({required this.from, required this.text});

  factory TextMessage.fromJson(String json) {
    final m = jsonDecode(json);
    return TextMessage(
      from: m['from'],
      text: m['text'],
    );
  }

  String toJson() => jsonEncode({
        'from': from,
        'text': text,
      });
}
