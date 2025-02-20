class TextMessage {
  final String? author;
  final String message;
  final bool isMy;

  TextMessage({this.author, required this.message, this.isMy = false});
}
