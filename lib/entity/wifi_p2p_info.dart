import 'platform_result.dart';
import 'device_role.dart';

class WifiP2PInfo extends PlatformResult {
  late final bool groupFormed;
  late final bool isGroupOwner;
  late final String? groupOwnerAddress;

  bool get isConnected => groupFormed && (groupOwnerAddress?.isNotEmpty == true);

  DeviceRole get deviceRole => (groupFormed)
      ? (isGroupOwner)
          ? DeviceRole.host
          : DeviceRole.client
      : DeviceRole.notConnected;

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
