import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/logger_widget.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import '/model/socket_chat_cubit_abstract.dart';
import '/model/socket_chat_state.dart';
import 'etc/confirm_dialog.dart';
import 'my_status_panel.dart';

class ChatPage extends StatefulWidget {
  final SocketChatCubitAbstract socketChatCubit;

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
          return BlocBuilder<SocketChatCubitAbstract, SocketChatState>(
            builder: (context, chatState) {
              return Scaffold(
                appBar: AppBar(
                  leadingWidth: 20,
                  title: DefaultTextStyle(style: TextStyle(), child: MyStatusPanel(forAppBar: true)),
                  actions: [
                    IconButton(
                      onPressed: _clearMessages,
                      icon: Icon(Icons.cleaning_services),
                      tooltip: 'Clear message history',
                    ),
                  ],
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
                              ...chatState.messages.reversed.map(
                                (m) => ListTile(
                                  visualDensity: VisualDensity.compact,
                                  title: (m.from == connector.me?.deviceName)
                                      ? Container(
                                          alignment: Alignment.centerRight,
                                          child: RichText(
                                            text: TextSpan(text: m.text),
                                          ),
                                        )
                                      : Container(
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            text: TextSpan(
                                              text: '${m.from}: ',
                                              style: TextStyle(color: Colors.red),
                                              children: [
                                                TextSpan(
                                                  text: m.text,
                                                  style: TextStyle(color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(
                          controller: _msgController,
                          onFieldSubmitted: _sendMessage,
                          // autofocus: true,
                        ),
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
    try {
      widget.socketChatCubit.sendMessage(msg);
      _msgController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '$e',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ));
    }
  }

  void _clearMessages() {
    showConfirmDialog(
      context,
      title: 'Delete all messages?',
      action: () async => widget.socketChatCubit.clearMessages(),
    );
  }

  @override
  void dispose() {
    // widget.socketChatCubit.closeChat();
    super.dispose();
  }
}
