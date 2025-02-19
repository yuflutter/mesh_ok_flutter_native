import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/wifi_p2p_info.dart';
import '/entity/socket_status.dart';
import '/entity/text_message.dart';
import 'etc/dowl.dart';
import 'socket_chat_state.dart';

const _port = 4045;

class SocketChatCubit extends Cubit<SocketChatState> {
  final WifiP2PInfo p2pInfo;

  late final WebSocket _socket;
  StreamSubscription? _socketSubscription;

  SocketChatCubit({required this.p2pInfo}) : super(SocketChatState.initial());

  Future<void> init() => switch (p2pInfo.deviceRole) {
        DeviceRole.client => _initClient(),
        DeviceRole.host => _initHost(),
      };

  Future<void> _initClient() async {
    final log = global<Logger>();
    try {
      final url = 'ws://${p2pInfo.groupOwnerAddress}:$_port/ws';
      log.i('connecting to $url ...');
      emit(state.copyWith(socketStatus: SocketStatus.connectingToHost));

      _socket = await WebSocket.connect(url);
      log.i('connected');
      emit(state.copyWith(socketStatus: SocketStatus.connected));

      _socketSubscription = _socket.listen(
        (msg) async {
          log.i('received message: "$msg"');
          emit(state.copyWith()..messages.add(TextMessage(msg)));
        },
        onError: (e, s) {
          log.e(this, e, s);
          close();
        },
        onDone: () {
          log.i('socket closed');
          close();
        },
      );
    } catch (e, s) {
      log.e(this, e, s);
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

  void sendMessage(String msg) {
    dowl('sendMessage()', () => _socket.add(msg));
    emit(state.copyWith()..messages.add(TextMessage(msg, isMy: true)));
  }

  @override
  Future<void> close() async {
    try {
      // Eсли close() вызвали принудительно - здесь будет падать
      emit(state.copyWith(socketStatus: SocketStatus.closed));
    } catch (_) {}
    await _socketSubscription?.cancel();
    await _socket.close();
    return super.close();
  }
}
