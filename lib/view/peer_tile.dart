import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/entity/peer.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import 'etc/confirm_dialog.dart';

class PeerTile extends StatelessWidget {
  final Peer peer;

  const PeerTile({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<P2pConnectorCubit, P2pConnectorState>(
      builder: (context, state) {
        return PopupMenuButton(
          position: PopupMenuPosition.under,
          offset: Offset(MediaQuery.of(context).size.width, -25),
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  enabled: (peer.status == PeerStatus.available),
                  onTap: () => _connectToPeer(context, peer),
                  child: Text('Connect to peer'),
                ),
                PopupMenuItem(
                  enabled: (peer.status == PeerStatus.connected),
                  onTap: () => _tryToOpenChat(context, peer),
                  child: Text('Open chat'),
                ),
                PopupMenuItem(
                  enabled: (peer.status != PeerStatus.available),
                  onTap: () => _disconnectMe(context),
                  child: Text('Disconnect'),
                ),
                // PopupMenuItem(
                //   onTap: () => _removeGroup(context),_disconnectFromGroup
                //   child: Text('Remove p2p group'),
                // ),
              ],
          child: ListTile(
            title: Text(peer.deviceName),
            subtitle: Text('${peer.all['primaryDeviceType']} / ${peer.all['deviceAddress']}'),
            trailing: Text(
              peer.status.caption,
              style: TextStyle(
                color: switch (peer.status) {
                  PeerStatus.invited => Colors.red,
                  PeerStatus.connected => Colors.green,
                  _ => null,
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _connectToPeer(BuildContext context, Peer peer) {
    showConfirmDialog(
      context,
      title: 'Connect to "${peer.deviceName}"?',
      action: () => context.read<P2pConnectorCubit>().connectPeer(peer),
    );
  }

  void _tryToOpenChat(BuildContext context, Peer peer) {
    // context.read<P2pConnectorCubit>().tryToOpenSocket();
  }

  void _disconnectMe(BuildContext context) {
    showConfirmDialog(context, title: 'Disconnect?', action: context.read<P2pConnectorCubit>().disconnectMe);
  }

  void _removeGroup(BuildContext context) {
    showConfirmDialog(context, title: 'Remove group?', action: context.read<P2pConnectorCubit>().removeGroup);
  }
}
