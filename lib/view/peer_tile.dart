import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/entity/wifi_p2p_device.dart';
import '/entity/wifi_p2p_info.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';
import 'etc/confirm_dialog.dart';

class PeerTile extends StatelessWidget {
  final WifiP2pDevice peer;

  const PeerTile({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<P2pConnectorCubit, P2pConnectorState>(
      builder: (context, state) {
        return PopupMenuButton(
          position: PopupMenuPosition.under,
          offset: Offset(MediaQuery.of(context).size.width, -25),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: (peer.status == PeerStatus.available),
              onTap: () => _connectToPeer(context, peer),
              child: Text('Connect to peer'),
            ),
            // PopupMenuItem(
            //   enabled: (peer.status == PeerStatus.connected && state.p2pInfo?.isConnected == true),
            //   onTap: () => _openChat(context, peer),
            //   child: Text('Open chat'),
            // ),
            PopupMenuItem(
              enabled: (peer.status != PeerStatus.available),
              onTap: () => _disconnectMe(context, state.p2pInfo),
              child: Text('Disconnect'),
            ),
          ],
          child: ListTile(
            visualDensity: VisualDensity.compact,
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

  void _connectToPeer(BuildContext context, WifiP2pDevice peer) {
    showConfirmDialog(
      context,
      title: 'Connect to "${peer.deviceName}"?',
      action: () => context.read<P2pConnectorCubit>().connectPeer(peer),
    );
  }

  // void _openChat(BuildContext context, WifiP2pDevice peer) {
  //   context.read<P2pConnectorCubit>().doOpenChat();
  // }

  void _disconnectMe(BuildContext context, WifiP2PInfo? p2pInfo) {
    showConfirmDialog(
      context,
      title: 'Disconnect from ${peer.deviceName}?',
      // title: (p2pInfo?.isGroupOwner == true) ? 'Remove group?' : 'Disconnect from group?',
      action: context.read<P2pConnectorCubit>().disconnectMe,
    );
  }
}
