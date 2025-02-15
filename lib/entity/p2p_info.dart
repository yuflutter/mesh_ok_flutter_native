// import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

// import 'device_role.dart';
// export 'device_role.dart';

// extension P2pInfoEx on WifiP2PInfo {
//   Map<String, dynamic> toJson() => {
//         'groupOwnerAddress': groupOwnerAddress,
//         'groupFormed': groupFormed,
//         'isGroupOwner': isGroupOwner,
//         'isConnected': isConnected,
//         'clients': clients.map((e) => e.deviceName).toList(),
//       };

//   static WifiP2PInfo fromJson(Map<String, dynamic> v) => WifiP2PInfo(
//         groupOwnerAddress: v['groupOwnerAddress'],
//         groupFormed: v['groupFormed'],
//         isGroupOwner: v['isGroupOwner'],
//         isConnected: v['isConnected'],
//         clients: [], // зачем сохранять клиентов между запусками - пока непонятно
//       );

//   DeviceRole get deviceRole => (isGroupOwner) ? DeviceRole.host : DeviceRole.client;
// }
