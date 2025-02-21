import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/theme_elements.dart';
import '/entity/device_role.dart';
import '/entity/socket_status.dart';
import '/model/p2p_connector_cubit.dart';
import '/model/p2p_connector_state.dart';

class MyStatusPanel extends StatelessWidget {
  final bool forAppBar;

  const MyStatusPanel({super.key, this.forAppBar = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<P2pConnectorCubit, P2pConnectorState>(
      builder: (context, state) {
        final p2pInfo = state.p2pInfo;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!forAppBar) Text('My status:', style: headerTextStyle),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 5, 10),
              child: (p2pInfo == null || !p2pInfo.groupFormed)
                  ? Text('Unknown')
                  : (p2pInfo.isError)
                      ? Text(p2pInfo.error!)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Group owner address: ${p2pInfo.groupOwnerAddress}'),
                            RichText(
                              text: TextSpan(
                                text: 'My device role: ',
                                children: [
                                  TextSpan(
                                    text: state.deviceRole.caption,
                                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Socket status: ',
                                children: [
                                  TextSpan(
                                    text: state.socketStatus.caption,
                                    style: TextStyle(color: Colors.yellowAccent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        );
      },
    );
  }
}
