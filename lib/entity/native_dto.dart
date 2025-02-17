import 'dart:convert';

/// Сущности приходят из MethodChannel либо как как объект json, либо как Map<Object?, Object?>.
/// Все поля складываем в all, а важные определяем явно в наследниках.
/// Если из котлина нужно вернуть ошибку или нулевой объект - сущность приходит как строка, а не как объект json или Map.
/// PS
/// Передача в виде бинарных Map<Object?, Object?> больше не используется.
class NativeDto {
  late final Map<String, dynamic> all;
  late final String? error;

  NativeDto.fromJson(String json) {
    final val = jsonDecode(json);
    if (val is Map) {
      all = val as Map<String, dynamic>;
      error = null;
    } else {
      all = {};
      error = val.toString();
    }
  }

  // NativeDto.fromMap(Map<Object?, Object?> map) : all = map.map((k, v) => MapEntry('$k', v as dynamic));
}
