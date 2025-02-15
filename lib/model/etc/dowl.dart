import 'dart:async';

import '/core/global.dart';
import '/core/logger.dart';

/// Выполняет функцию и логирует её результат (do with log)
FutureOr<T> dowl<T>(String msg, FutureOr<T> Function() func) async {
  final logger = global<Logger>();
  final res = await func();
  final ress = res.toString();
  // Неудача возвращается как false, это лишь особенность wifi-direct реализации
  if (res == false || ress.endsWith('denied') || ress.endsWith('null')) {
    logger.warn('$msg => $ress');
  } else {
    logger.info('$msg => $ress');
  }
  return res;
}
