enum SocketStatus { notConnected, waitingIncoming, connectingToHost, connected, closed }

extension SocketStatusEx on SocketStatus {
  String get caption => switch (this) {
        SocketStatus.notConnected => 'not connected',
        SocketStatus.waitingIncoming => 'waiting for incoming...',
        SocketStatus.connectingToHost => 'connecting to host...',
        SocketStatus.connected => 'connected',
        SocketStatus.closed => 'closed',
      };
}
