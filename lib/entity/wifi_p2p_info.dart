import 'platform_result.dart';

enum DeviceRole { client, host }

extension DeviceRoleEx on DeviceRole {
  String get caption => switch (this) {
        DeviceRole.client => 'client',
        DeviceRole.host => 'host (server)',
      };
}

class WifiP2PInfo extends PlatformResult {
  late final bool groupFormed;
  late final bool isGroupOwner;
  late final String? groupOwnerAddress;

  bool get isConnected => groupFormed && (groupOwnerAddress?.isNotEmpty == true);

  DeviceRole get deviceRole => (isGroupOwner) ? DeviceRole.host : DeviceRole.client;

  WifiP2PInfo.fromJson(super.json) : super.fromJson() {
    if (isError) {
      groupFormed = false;
      isGroupOwner = false;
      groupOwnerAddress = '';
    } else {
      groupFormed = all['groupFormed'];
      isGroupOwner = all['isGroupOwner'];
      groupOwnerAddress = all['groupOwnerAddress'];
    }
  }
}
