import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/logger_widget.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import '/model/socket_cubit.dart';
import '/model/socket_state.dart';
import 'my_status_panel.dart';

class ChatPage extends StatefulWidget {
  final SocketCubit socketCubit;

  const ChatPage({super.key, required this.socketCubit});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.socketCubit,
      child: BlocBuilder<P2pConnectorCubit, P2pConnectorState>(
        builder: (context, connector) {
          return BlocBuilder<SocketCubit, SocketState>(
            builder: (context, socket) {
              return Scaffold(
                appBar: AppBar(
                  title: DefaultTextStyle(style: TextStyle(), child: MyStatusPanel(forAppBar: true)),
                  // title: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.stretch,
                  //   children: [
                  //     Text(connector.p2pGroupInfo?.groupNetworkName ?? 'groupNetworkName???'),
                  //     Text(connector.p2pInfo?.groupOwnerAddress ?? 'groupOwnerAddress???', style: headerTextStyle),
                  //   ],
                  // ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListView(
                            children: [
                              ...socket.messages.reversed.map(
                                (m) => ListTile(
                                  title: Container(
                                    alignment: (m.isMy) ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Text(m.message),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(controller: _msgController, autofocus: true, onFieldSubmitted: _senfMessage),
                        SizedBox(height: 8),
                        if (MediaQuery.of(context).viewInsets.bottom == 0) Expanded(child: LoggerWidget()),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _senfMessage(String msg) {
    widget.socketCubit.sendMessage(msg);
    _msgController.clear();
  }
}
