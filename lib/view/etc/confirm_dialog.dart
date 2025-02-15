import 'package:flutter/material.dart';

import '/core/theme_elements.dart';

Future<T?> showConfirmDialog<T>(
  BuildContext context, {
  required String title,
  required Future<T> Function() action,
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => _Dialog(title: title, action: action),
  );
}

class _Dialog<T> extends StatefulWidget {
  final String title;
  final Future<T> Function() action;

  const _Dialog({required this.title, required this.action});

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: Text(widget.title, style: headerTextStyle),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() => _processing = true);
                final result = await widget.action();
                if (context.mounted) Navigator.of(context).pop(result);
              },
              child: Text('OK'),
            ),
          ],
        ),
        if (_processing) Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ],
    );
  }
}
