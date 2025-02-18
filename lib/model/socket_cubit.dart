import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';
import '/entity/text_message.dart';
import 'etc/dowl.dart';
import 'socket_state.dart';

const _port = 4045;

class SocketCubit extends Cubit<SocketState> {
  final WifiP2PInfo p2pInfo;
  late final WebSocket _socket;

  final _socketStatusController = StreamController<SocketStatus>();
  Stream<SocketStatus> get socketStatusStream => _socketStatusController.stream;

  StreamSubscription? _socketSubscription;

  SocketCubit({required this.p2pInfo}) : super(SocketState.initial());

  Future<void> init() async {
    switch (p2pInfo.deviceRole) {
      case DeviceRole.host:
        return _initHost();
      case DeviceRole.client:
        return _initClient();
    }
  }

  Future<void> _initHost() async {
    // final log = global<Logger>();
    // await Future.value();
    // log.info("starting server socket...");
    // final res = dowl(
    //   'startSocket(${p2pInfo.groupOwnerAddress})',
    //   () => _conn.startSocket(
    //     groupOwnerAddress: p2pInfo.groupOwnerAddress,
    //     downloadPath: "/storage/emulated/0/Download/",
    //     onConnect: (name, address) {
    //       log.info("$name ($address) connected");
    //       _socketStatusController.add(SocketStatus.connected);
    //     },
    //     receiveString: (msg) async {
    //       log.info('received string: "$msg"');
    //       emit(state.copyWith()..messages.add(TextMessage(msg)));
    //     },
    //     transferUpdate: (transfer) {
    //       // transfer.count is the amount of bytes transfered
    //       // transfer.total is the file size in bytes
    //       // if transfer.receiving is true, you are receivin the file, else you're sending the file.
    //       // call `transfer.cancelToken?.cancel()` to cancel transfer. This method is only applicable to receiving transfers.
    //       log.info(
    //         "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}",
    //       );
    //     },
    //     onCloseSocket: () {
    //       log.info("socket closed");
    //       _socketStatusController.add(SocketStatus.notConnected);
    //     },
    //   ),
    // );
    // _socketStatusController.add(SocketStatus.waitingIncoming);
    // return res;
  }

  Future<void> _initClient() async {
    final log = global<Logger>();
    try {
      final url = 'ws://${p2pInfo.groupOwnerAddress}:$_port/ws';
      log.i('connecting to $url ...');
      _socketStatusController.add(SocketStatus.connectingToHost);
      _socket = await WebSocket.connect(url);
      log.i('connected');
      _socketStatusController.add(SocketStatus.connected);
      _socketSubscription = _socket.listen(
        (msg) async {
          log.i('received message: "$msg"');
          emit(state.copyWith()..messages.add(TextMessage(msg)));
        },
        onError: (e, s) => log.e(this, e, s),
        cancelOnError: true,
      );
    } catch (e, s) {
      log.e(this, e, s);
    }

    // await Future.value();
    // log.i("connecting to ${p2pInfo.groupOwnerAddress}...");
    // _socketStatusController.add(SocketStatus.connectingToHost);
    // final res = await dowl(
    //   'connectToSocket(${p2pInfo.groupOwnerAddress})',
    //   () => _conn.connectToSocket(
    //     groupOwnerAddress: p2pInfo.groupOwnerAddress,
    //     downloadPath: "/storage/emulated/0/Download/",
    //     maxConcurrentDownloads: 2,
    //     // delete incomplete transfered file
    //     deleteOnError: true,
    //     onConnect: (address) {
    //       log.i("connected to: $address");
    //       _socketStatusController.add(SocketStatus.connected);
    //     },
    //     // receive transfer updates for both sending and receiving.
    //     transferUpdate: (transfer) {
    //       // transfer.count is the amount of bytes transfered
    //       // transfer.total is the file size in bytes
    //       // if transfer.receiving is true, you are receiving the file, else you're sending the file.
    //       // call `transfer.cancelToken?.cancel()` to cancel transfer. This method is only applicable to receiving transfers.
    //       log.i(
    //         "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}",
    //       );
    //     },
    //     receiveString: (msg) async {
    //       log.i('received string: "$msg"');
    //       emit(state.copyWith()..messages.add(TextMessage(msg)));
    //     },
    //     onCloseSocket: () {
    //       log.i("socket closed");
    //       _socketStatusController.add(SocketStatus.notConnected);
    //     },
    //   ),
    // );
    // if (!res) _socketStatusController.add(SocketStatus.notConnected);
    // return res;
  }

  void sendMessage(String msg) {
    dowl('sendMessage()', () => _socket.add(msg));
    emit(state.copyWith()..messages.add(TextMessage(msg, isMy: true)));
  }

  @override
  Future<void> close() {
    // TODO: Это не работает, переделать полностью
    _socketStatusController.add(SocketStatus.notConnected);
    _socketStatusController.close();
    _socketSubscription?.cancel();
    _socket.close();
    return super.close();
  }
}
