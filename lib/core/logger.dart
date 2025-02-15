import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import '/app_config.dart';
import 'global.dart';

/// Простейший in-memory логгер.
class Logger with ChangeNotifier {
  late final _maxLogsSaved = global<AppConfig>().maxLogsSaved;

  final List<_Log> _lastLogs = [];

  void info(dynamic info) {
    _addLog(_Log('INFO', info.toString()));
  }

  void warn(dynamic warn) {
    _addLog(_Log('WARN', warn.toString()));
  }

  void error(String source, Object error, [StackTrace? stack]) {
    _addLog(_Log('ERROR', 'in $source: $error\n$stack'));
  }

  void _addLog(_Log l) {
    if (kDebugMode) {
      dev.log(l.toString());
    } else {
      print(l.toString());
    }
    _lastLogs.add(l);
    if (_lastLogs.length > _maxLogsSaved) {
      _lastLogs.removeAt(0);
    }
    notifyListeners();
  }

  List<String> lastLogs({bool reversed = true, String dateFormat = 'dd.MM HH:mm:ss'}) {
    final df = (dateFormat.isNotEmpty) ? DateFormat(dateFormat) : null;
    final res = _lastLogs.map<String>((e) {
      if (df != null) {
        return '${e.level} [${df.format(e.when)}] ${e.what}';
      } else {
        return '${e.level}: ${e.what}';
      }
    }).toList();
    return (reversed) ? res.reversed.toList() : res;
  }

  void clear() {
    _lastLogs.clear();
    notifyListeners();
  }
}

final _defaultDateFommat = DateFormat('dd.MM HH:mm:ss');

class _Log {
  String level;
  DateTime when;
  String what;

  _Log(this.level, this.what) : when = DateTime.now();

  @override
  String toString() => '$level [${_defaultDateFommat.format(when)}] $what';
}
