enum DeviceRole { notConnected, client, host }

extension DeviceRoleEx on DeviceRole {
  String get caption => switch (this) {
        DeviceRole.notConnected => 'not connected',
        DeviceRole.client => 'client',
        DeviceRole.host => 'host (server)',
      };
}
