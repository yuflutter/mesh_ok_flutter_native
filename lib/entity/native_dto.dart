/// Сущности приходят из MethodChannel в виде Map<Object?, Object?>.
/// Все поля складываем в all, а важные определяем явно в наследниках
class NativeDto {
  final Map<String, dynamic> all;

  NativeDto.fromDto(Map<Object?, Object?> dto)
      : all = dto.map(
          (k, v) => MapEntry('$k', v as dynamic),
        );
}
