import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/logger_widget.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import '/model/socket_chat_cubit.dart';
import '/model/socket_chat_state.dart';
import 'my_status_panel.dart';

class ChatPage extends StatefulWidget {
  final SocketChatCubit socketChatCubit;

  const ChatPage({super.key, required this.socketChatCubit});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.socketChatCubit,
      child: BlocBuilder<P2pConnectorCubit, P2pConnectorState>(
        builder: (context, connector) {
          return BlocBuilder<SocketChatCubit, SocketChatState>(
            builder: (context, socket) {
              return Scaffold(
                appBar: AppBar(
                  title: DefaultTextStyle(style: TextStyle(), child: MyStatusPanel(forAppBar: true)),
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
                                  title: (m.from == connector.me?.deviceName)
                                      ? Container(
                                          alignment: Alignment.centerRight,
                                          child: Text(m.text),
                                        )
                                      : Container(
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            text: TextSpan(
                                              text: '${m.from}: ',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                              children: [TextSpan(text: m.text)],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(controller: _msgController, autofocus: true, onFieldSubmitted: _sendMessage),
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

  void _sendMessage(String msg) {
    widget.socketChatCubit.sendMessage(msg);
    _msgController.clear();
  }

  @override
  void dispose() {
    widget.socketChatCubit.close();
    super.dispose();
  }
}
