import 'package:flutter/material.dart';

/// Вывод ошибки, возникающей в build(), с возможностью скролла и копирования.
/// Заменяет стандартный ErrorWidget в main().
class StrongErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;

  const StrongErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.redAccent,
        child: SelectableText('$error'),
      ),
    );
  }
}
