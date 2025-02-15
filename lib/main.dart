import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app_config.dart';
import '/core/global.dart';
import '/core/logger.dart';
import '/core/strong_error_widget.dart';
import '/data/p2p_info_repository.dart';
import '/model/p2p_connector_cubit.dart';
import '/view/home_page.dart';

void main() {
  // Глобальные инстансы инжектим в Global, остальные - в BuildContext.
  Global.putAll([AppConfig(), Logger()]);
  ErrorWidget.builder = (e) => StrongErrorWidget(error: e);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => P2pConnectorCubit(repository: P2pInfoRepository()))],
      child: MaterialApp(
        title: global<AppConfig>().appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
