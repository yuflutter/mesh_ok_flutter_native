// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

// import '/core/global.dart';
// import '/core/logger.dart';
// import '/entity/p2p_info.dart';
// import '/entity/socket_status.dart';
// import '/entity/text_message.dart';
// import 'etc/dowl.dart';
// import 'socket_state.dart';

// class SocketCubit extends Cubit<SocketState> {
//   final WifiP2PInfo p2pInfo;
//   final _conn = FlutterP2pConnection();

//   final _socketStatusController = StreamController<SocketStatus>();
//   Stream<SocketStatus> get socketStatusStream => _socketStatusController.stream;

//   SocketCubit({required this.p2pInfo}) : super(SocketState.initial());

//   Future<bool> init() async {
//     try {
//       _conn.closeSocket(notify: false);
//     } catch (_) {}
//     switch (p2pInfo.deviceRole) {
//       case DeviceRole.host:
//         return _initHost();
//       case DeviceRole.client:
//         return _initClient();
//     }
//   }

//   Future<bool> _initHost() async {
//     final logger = global<Logger>();
//     await Future.value();
//     logger.info("starting server socket...");
//     final res = dowl(
//       'startSocket(${p2pInfo.groupOwnerAddress})',
//       () => _conn.startSocket(
//         groupOwnerAddress: p2pInfo.groupOwnerAddress,
//         downloadPath: "/storage/emulated/0/Download/",
//         onConnect: (name, address) {
//           logger.info("$name ($address) connected");
//           _socketStatusController.add(SocketStatus.connected);
//         },
//         receiveString: (msg) async {
//           logger.info('received string: "$msg"');
//           emit(state.copyWith()..messages.add(TextMessage(msg)));
//         },
//         transferUpdate: (transfer) {
//           // transfer.count is the amount of bytes transfered
//           // transfer.total is the file size in bytes
//           // if transfer.receiving is true, you are receivin the file, else you're sending the file.
//           // call `transfer.cancelToken?.cancel()` to cancel transfer. This method is only applicable to receiving transfers.
//           logger.info(
//             "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}",
//           );
//         },
//         onCloseSocket: () {
//           logger.info("socket closed");
//           _socketStatusController.add(SocketStatus.notConnected);
//         },
//       ),
//     );
//     _socketStatusController.add(SocketStatus.waitingIncoming);
//     return res;
//   }

//   Future<bool> _initClient() async {
//     final logger = global<Logger>();
//     await Future.value();
//     logger.info("connecting to ${p2pInfo.groupOwnerAddress}...");
//     _socketStatusController.add(SocketStatus.connectingToHost);
//     final res = await dowl(
//       'connectToSocket(${p2pInfo.groupOwnerAddress})',
//       () => _conn.connectToSocket(
//         groupOwnerAddress: p2pInfo.groupOwnerAddress,
//         downloadPath: "/storage/emulated/0/Download/",
//         maxConcurrentDownloads: 2,
//         // delete incomplete transfered file
//         deleteOnError: true,
//         onConnect: (address) {
//           logger.info("connected to: $address");
//           _socketStatusController.add(SocketStatus.connected);
//         },
//         // receive transfer updates for both sending and receiving.
//         transferUpdate: (transfer) {
//           // transfer.count is the amount of bytes transfered
//           // transfer.total is the file size in bytes
//           // if transfer.receiving is true, you are receiving the file, else you're sending the file.
//           // call `transfer.cancelToken?.cancel()` to cancel transfer. This method is only applicable to receiving transfers.
//           logger.info(
//             "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}",
//           );
//         },
//         receiveString: (msg) async {
//           logger.info('received string: "$msg"');
//           emit(state.copyWith()..messages.add(TextMessage(msg)));
//         },
//         onCloseSocket: () {
//           logger.info("socket closed");
//           _socketStatusController.add(SocketStatus.notConnected);
//         },
//       ),
//     );
//     if (!res) _socketStatusController.add(SocketStatus.notConnected);
//     return res;
//   }

//   void sendMessage(String msg) {
//     dowl('sendStringToSocket()', () => _conn.sendStringToSocket(msg));
//     emit(state.copyWith()..messages.add(TextMessage(msg, isMy: true)));
//   }

//   @override
//   Future<void> close() {
//     // TODO: Это не работает, переделать полностью
//     _conn.closeSocket();
//     _socketStatusController.add(SocketStatus.notConnected);
//     _socketStatusController.close();
//     return super.close();
//   }
// }
