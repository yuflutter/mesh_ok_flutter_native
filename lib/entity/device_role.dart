enum DeviceRole { host, client }

extension DeviceRoleEx on DeviceRole {
  String get caption => switch (this) {
        DeviceRole.host => 'host (server)',
        DeviceRole.client => 'client',
      };
}
