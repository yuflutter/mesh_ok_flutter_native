import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/theme_elements.dart';
import '/entity/device_role.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import '../model/socket_chat_cubit_stub.dart';
import '/model/socket_chat_state.dart';

class MyStatusPanel extends StatelessWidget {
  final bool forAppBar;

  const MyStatusPanel({super.key, this.forAppBar = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<P2pConnectorCubit, P2pConnectorState>(
      builder: (context, p2pState) {
        return BlocBuilder<SocketChatCubitStub, SocketChatState>(
          bloc: p2pState.socketChatCubit,
          builder: (context, chanState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!forAppBar) Text('My status:', style: headerTextStyle),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 5, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p2pState.myDevice == null)
                        Text('Unknown')
                      else ...[
                        if (!forAppBar)
                          RichText(
                            text: TextSpan(
                              text: 'Device name: ',
                              children: [
                                TextSpan(
                                  text: p2pState.myDevice!.deviceName,
                                  style: TextStyle(color: Colors.greenAccent),
                                )
                              ],
                            ),
                          ),
                        if (p2pState.p2pInfo?.isError == true)
                          Text(p2pState.p2pInfo!.error!)
                        else if (p2pState.p2pInfo?.isConnected != true)
                          Text("Not connected")
                        else ...[
                          RichText(
                            text: TextSpan(
                              text: 'Device role: ',
                              children: [
                                TextSpan(
                                  text: p2pState.deviceRole.caption,
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Group owner address: ${p2pState.p2pInfo!.groupOwnerAddress}',
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Socket status: ',
                              children: [
                                TextSpan(
                                  text: chanState.socketStatus.caption,
                                  style: TextStyle(color: Colors.yellowAccent),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
