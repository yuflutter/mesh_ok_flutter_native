import 'platform_result.dart';
import 'device_role.dart';
export 'device_role.dart';

class WifiP2PInfo extends PlatformResult {
  late final bool groupFormed;
  late final bool isGroupOwner;
  late final String groupOwnerAddress;

  bool get isConnected => groupFormed && groupOwnerAddress.isNotEmpty;

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
