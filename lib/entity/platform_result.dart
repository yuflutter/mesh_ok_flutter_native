import 'dart:convert';

/// Сущности приходят из PlatformChannel либо как как объект json, либо как Map<Object?, Object?>.
/// Все поля складываем в all, а важные - определяем явно в наследниках.
/// Если из котлина нужно вернуть ошибку или нулевой объект - сущность приходит как объект с одним полем error
/// PS
/// Передача в виде бинарных Map<Object?, Object?> больше не используется ввиду некорректной конвертации int.
class PlatformResult {
  late final Map<String, dynamic> all;
  late final String? error;

  bool get isError => (error != null);

  PlatformResult.fromJson(String json) {
    all = jsonDecode(json);
    error = all['error'];
  }

  String toJson() => jsonEncode(all);

  // NativeDto.fromMap(Map<Object?, Object?> map) : all = map.map((k, v) => MapEntry('$k', v as dynamic));
}
