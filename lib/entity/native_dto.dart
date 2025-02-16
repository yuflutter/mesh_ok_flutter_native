import 'dart:convert';

/// Сущности приходят из MethodChannel в виде Map<Object?, Object?>, или JSON.
/// Все поля складываем в all, а важные - определяем явно в наследниках.
class NativeDto {
  final Map<String, dynamic> all;

  NativeDto.fromMap(Map<Object?, Object?> map) : all = map.map((k, v) => MapEntry('$k', v as dynamic));

  NativeDto.fromJson(String json) : all = jsonDecode(json) as Map<String, dynamic>;
}
