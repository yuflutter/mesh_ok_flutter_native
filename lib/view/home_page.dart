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
  final Future initFuture;

  const HomePage({super.key, required this.initFuture});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future _refreshFuture = Future.value();

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder(
      future: widget.initFuture,
      builder: (context, _) {
        return BlocConsumer<P2pConnectorCubit, P2pConnectorState>(
          builder: (context, p2pState) {
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
                            child: ListView(
                              children: [
                                ...p2pState.peers.map((peer) => PeerTile(peer: peer)),
                              ],
                            ),
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
                  onTap: (i) => switch (i) {
                    0 => global<Logger>().clear(),
                    1 => _refreshAll(),
                    2 => openChat(),
                    _ => null,
                  },
                  items: [
                    BottomNavigationBarItem(label: 'Clear log', icon: Icon(Icons.clear)),
                    BottomNavigationBarItem(label: 'Refresh all', icon: Icon(Icons.refresh)),
                    BottomNavigationBarItem(label: 'Open chat', icon: Icon(Icons.chat)),
                  ],
                ),
              ),
            );
          },
          listener: (context, state) {
            if (state.doOpenChat) {
              openChat();
            }
          },
        );
      },
    );
  }

  void openChat() {
    const routeName = 'socket_chat';
    final socketChatCubit = context.read<P2pConnectorCubit>().state.socketChatCubit;
    // TODO: canPop() - это костыль, добавить явную проверку, что именно чат уже открыт!
    if (socketChatCubit != null && !Navigator.of(context).canPop()) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatPage(socketChatCubit: socketChatCubit),
        settings: RouteSettings(name: routeName),
      ));
    }
  }

  // Ставим задержку для улучшения пользовательского опыта ))
  void _refreshAll() {
    setState(() {
      _refreshFuture = () async {
        await context.read<P2pConnectorCubit>().refreshAll();
        await Future.delayed(Duration(seconds: 1));
      }();
    });
  }
}
