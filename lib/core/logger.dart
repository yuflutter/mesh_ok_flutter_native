import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import '/app_config.dart';
import 'global.dart';

final _consoleDateFormat = DateFormat('dd.MM HH:mm:ss');

/// Простейший in-memory логгер.
class Logger with ChangeNotifier {
  final String? uiDateFormat;
  late final DateFormat? _uiDateFormat = (uiDateFormat?.isNotEmpty == true) ? DateFormat(uiDateFormat) : null;

  final List<_Log> _lastLogs = [];
  late final _maxLogsSaved = global<AppConfig>().maxLogNumber;

  Logger({this.uiDateFormat = 'HH:mm:ss'});

  /// Info
  void i(dynamic info, {bool consoleOnly = false}) {
    _addLog(_Log('', info.toString()), consoleOnly);
  }

  /// Warning
  void w(dynamic warn, {bool consoleOnly = false}) {
    _addLog(_Log('WARN ', warn.toString()), consoleOnly);
  }

  /// Error
  void e(dynamic source, Object e, [StackTrace? s]) {
    final sourceText = switch (source) {
      String() => source,
      Object() => source.runtimeType,
      _ => source.toString(),
    };
    _addLog(_Log('ERROR ', 'in $sourceText: $e${(s != null) ? '\n$s' : ''}'));
  }

  void _addLog(_Log log, [bool consoleOnly = false]) {
    if (kDebugMode) {
      dev.log(log.toConsole());
    } else {
      print(log.toConsole());
    }
    if (!consoleOnly) {
      _lastLogs.add(log);
      if (_lastLogs.length > _maxLogsSaved) {
        _lastLogs.removeAt(0);
      }
      notifyListeners();
    }
  }

  List<String> lastLogs({bool reversed = true}) {
    final res = _lastLogs.map<String>((e) {
      if (_uiDateFormat != null) {
        return '${e.level}[${_uiDateFormat.format(e.when)}] ${e.what}';
      } else {
        return '${e.level}${e.what}';
      }
    }).toList();
    return (reversed) ? res.reversed.toList() : res;
  }

  void clear() {
    _lastLogs.clear();
    notifyListeners();
  }
}

class _Log {
  final String level;
  final DateTime when;
  final String what;

  _Log(this.level, this.what) : when = DateTime.now();

  String toConsole() => '$level[${_consoleDateFormat.format(when)}] $what';
}
