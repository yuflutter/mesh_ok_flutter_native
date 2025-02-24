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
                  leadingWidth: 40,
                  titleSpacing: 0,
                  title: DefaultTextStyle(
                    style: TextStyle(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: MyStatusPanel(forAppBar: true),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _clearMessages,
                      icon: Icon(Icons.cleaning_services),
                      tooltip: 'Clear message history',
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ListView(
                                reverse: true,
                                children: [
                                  ...chatState.messages.reversed.map(
                                    (m) => ListTile(
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.zero,
                                      title: (m.from == connector.me?.deviceName)
                                          ? Container(
                                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 4),
                                              alignment: AlignmentDirectional.centerEnd,
                                              child: RichText(
                                                text: TextSpan(
                                                  text: 'me: ',
                                                  style: TextStyle(color: Colors.red),
                                                  children: [
                                                    TextSpan(
                                                      text: m.text,
                                                      style: TextStyle(color: Colors.white),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
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
                              // onFieldSubmitted: _sendMessage,
                              // autofocus: true,
                              minLines: 1,
                              maxLines: 5,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 40, 0),
                              ),
                            ),
                            SizedBox(height: 8),
                            if (MediaQuery.of(context).viewInsets.bottom == 0) Expanded(child: LoggerWidget()),
                          ],
                        ),
                      ),
                      if (MediaQuery.of(context).viewInsets.bottom != 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                          // child: FloatingActionButton.small(
                          child: IconButton.filled(
                            onPressed: _sendMessage,
                            tooltip: 'Send message',
                            icon: Icon(Icons.send),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _sendMessage() {
    try {
      final msg = _msgController.text.trim();
      if (msg.isNotEmpty) {
        widget.socketChatCubit.sendMessage(msg);
        _msgController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', style: TextStyle(fontWeight: FontWeight.bold)),
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
