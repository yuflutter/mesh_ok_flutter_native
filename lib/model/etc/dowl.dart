import 'dart:async';

import '/core/global.dart';
import '/core/logger.dart';

/// Выполняет функцию и логирует её результат (do with log)
FutureOr<T> dowl<T>(String msg, FutureOr<T> Function() func) async {
  final log = global<Logger>();
  final res = await func();
  log.i('$msg => $res');
  return res;
}
