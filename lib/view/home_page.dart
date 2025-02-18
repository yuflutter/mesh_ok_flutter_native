import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/core/theme_elements.dart';
import '/core/logger_widget.dart';
import '/core/simple_future_builder.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import 'my_status_panel.dart';
import 'peer_tile.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future _initFuture;
  Future _refreshFuture = Future.value();

  @override
  void initState() {
    _initFuture = context.read<P2pConnectorCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder(
      future: _initFuture,
      builder: (context, _) {
        return BlocConsumer<P2pConnectorCubit, P2pConnectorState>(
          builder: (context, state) {
            return SafeArea(
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyStatusPanel(),
                          Text('Discovered peers:', style: headerTextStyle),
                          Expanded(
                            flex: 2,
                            child: ListView(children: [...state.peers.map((peer) => PeerTile(peer: peer))]),
                          ),
                          SizedBox(height: 3),
                          Expanded(flex: 3, child: LoggerWidget()),
                        ],
                      ),
                      // Демонстрация, как можно избавиться от флагов isWaiting в стейте.
                      // Future сама по себе является таким флагом, и не нужно плодить сущности.
                      // SimpleFutureBuilder рисует прелоадер, пока фьюча выполняется.
                      SimpleFutureBuilder(future: _refreshFuture, builder: (context, _) => SizedBox()),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  onTap:
                      (i) => switch (i) {
                        0 => global<Logger>().clear(),
                        1 => _refresh(),
                        _ => null,
                      },
                  items: [
                    BottomNavigationBarItem(label: 'Clear log', icon: Icon(Icons.clear)),
                    BottomNavigationBarItem(label: 'Refresh', icon: Icon(Icons.refresh)),
                  ],
                ),
              ),
            );
          },
          listener: (context, state) {
            if (state.justConnectedSocket != null) {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ChatPage(socketCubit: state.justConnectedSocket!)));
            }
          },
        );
      },
    );
  }

  // Ставим задержку для улучшения пользовательского опыта ))
  void _refresh() {
    setState(() {
      _refreshFuture = () async {
        await context.read<P2pConnectorCubit>().refreshAll();
        await Future.delayed(Duration(seconds: 1));
      }();
    });
  }
}
