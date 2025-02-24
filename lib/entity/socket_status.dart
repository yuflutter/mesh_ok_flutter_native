// Боролся за минимизацию количество букв, прошу понять и простить.)

sealed class SocketStatus {
  const SocketStatus();
  String get caption;
}

class SocketStatusNotConnected extends SocketStatus {
  const SocketStatusNotConnected();
  get caption => 'not connected';
}

class SocketStatusWaitingIncoming extends SocketStatus {
  get caption => 'waiting for incoming...';
}

class SocketStatusConnectingToHost extends SocketStatus {
  final int attemptsCount;
  SocketStatusConnectingToHost([this.attemptsCount = 0]);
  SocketStatusConnectingToHost operator +(int other) => SocketStatusConnectingToHost(attemptsCount + other);
  get caption => 'connecting to host...${(attemptsCount > 0) ? '($attemptsCount)' : ''}';
}

class SocketStatusConnectedAsClient extends SocketStatus {
  get caption => 'connected';
}

class SocketStatusConnectedAsHost extends SocketStatus {
  final int clientCount;
  SocketStatusConnectedAsHost([this.clientCount = 1]);
  get caption => 'connected ($clientCount)';
}

class SocketStatusClosed extends SocketStatus {
  get caption => 'closed';
}
