import 'package:flutter/material.dart';

/// Синтаксический сахар для FutureBuilder.
class SimpleFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T? data) builder;
  final Widget? placeholder;
  final Widget Function(String error)? errorBuilder;

  const SimpleFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  build(context) {
    return FutureBuilder<T?>(
      future: future,
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? placeholder ?? Center(child: CircularProgressIndicator())
            : snapshot.hasError
                ? (errorBuilder != null)
                    ? errorBuilder!(snapshot.error!.toString())
                    : ErrorWidget(snapshot.error!)
                : builder(context, (snapshot.hasData) ? snapshot.requireData : null);
      },
    );
  }
}
