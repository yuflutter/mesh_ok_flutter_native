// Реализация сильных enum через type extension
enum PeerStatus { available, invited, connected }

extension PeerStatuses on PeerStatus {
  static final Map<PeerStatus, ({int id, String name})> _values = {
    PeerStatus.available: (id: 3, name: 'Доступно'),
    PeerStatus.invited: (id: 1, name: 'Приглашено'),
    PeerStatus.connected: (id: 0, name: 'Подключено'),
  };

  static PeerStatus fromId(int id) {
    for (var e in _values.entries) {
      if (e.value.id == id) return e.key;
    }
    throw 'Unknown PeerStatus.id == $id';
  }

  int get id => _values[this]!.id;
  String get name => _values[this]!.name;
}

void testPeerStatus() {
  final v = PeerStatuses.fromId(1);
  final name = switch (v) {
    PeerStatus.available => v.name,
    PeerStatus.invited => v.name,
    PeerStatus.connected => v.name,
  };
  print(name);
}
