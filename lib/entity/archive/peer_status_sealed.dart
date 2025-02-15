// Реализация сильных enum через sealed classes
sealed class PeerStatus {
  int id;
  String name;

  PeerStatus._(this.id, this.name);

  factory PeerStatus.fromId(int id) => switch (id) {
        3 => PeerAvailable(),
        1 => PeerInvited(),
        0 => PeerConnected(),
        _ => throw 'Unknown PeerStatus.id == $id',
      };

  static final List<PeerStatus> values = [PeerAvailable(), PeerInvited(), PeerConnected()];

  @override
  bool operator ==(Object other) {
    return (other is PeerStatus) ? id == other.id : false;
  }
}

class PeerAvailable extends PeerStatus {
  PeerAvailable() : super._(3, 'Доступно');
}

class PeerInvited extends PeerStatus {
  PeerInvited() : super._(1, 'Приглашено');
}

class PeerConnected extends PeerStatus {
  PeerConnected() : super._(0, 'Подключено');
}

void testPeerStatus() {
  final v = PeerStatus.fromId(1);
  final name = switch (v) {
    PeerAvailable() => v.name,
    PeerInvited() => v.name,
    PeerConnected() => v.name,
  };
  print(name);
}
