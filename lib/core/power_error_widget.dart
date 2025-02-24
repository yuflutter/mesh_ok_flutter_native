import 'package:flutter/material.dart';

/// Вывод ошибки, возникающей в build(), с возможностью скролла и копирования.
/// Заменяет стандартный ErrorWidget в main().
/// Слово Powerful здесь означает шутку.
class PowerfulErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;

  const PowerfulErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.redAccent,
            child: SelectableText('$error\n${error.stack}'),
          ),
        ),
      ),
    );
  }
}
