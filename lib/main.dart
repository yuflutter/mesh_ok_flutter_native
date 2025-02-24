import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app_config.dart';
import '/core/global.dart';
import '/core/logger.dart';
import 'core/power_error_widget.dart';
import '/data/chat_repository.dart';
import '/model/p2p_connector_cubit.dart';
import '/view/home_page.dart';

void main() {
  // Инстансы, которые должны быть глобально доступны вне BuildContext, инжектим в Global.
  Global.putAll([
    AppConfig(),
    Logger(),
    SimpleDumbChatRepository(),
  ]);
  ErrorWidget.builder = (e) => PowerfulErrorWidget(error: e);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _p2pConnectorCubit = P2pConnectorCubit();

  late final _initFuture = () async {
    await global<AbstractChatRepository>().init();
    await _p2pConnectorCubit.init();
  }();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _p2pConnectorCubit),
      ],
      child: MaterialApp(
        title: global<AppConfig>().appTitle,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        ),
        home: HomePage(initFuture: _initFuture),
      ),
    );
  }
}
