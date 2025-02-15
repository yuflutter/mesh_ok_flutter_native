import 'package:flutter/material.dart';

import 'global.dart';
import 'logger.dart';
import 'theme_elements.dart';

class LoggerWidget extends StatelessWidget {
  const LoggerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = global<Logger>();
    return ListenableBuilder(
      listenable: logger,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Last logs:', style: headerTextStyle),
            Expanded(
              child: ListView(
                children: [
                  ...logger.lastLogs(dateFormat: 'mm:ss').map((e) => SelectableText(e)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
