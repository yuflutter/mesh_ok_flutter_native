import 'dart:convert';

import 'native_dto.dart';
import 'device_role.dart';
export 'device_role.dart';

class WifiP2PInfo extends NativeDto {
  late final bool groupFormed;
  late final bool isGroupOwner;
  late final String groupOwnerAddress;

  DeviceRole get deviceRole => (isGroupOwner) ? DeviceRole.host : DeviceRole.client;

  WifiP2PInfo.fromJson(super.json) : super.fromJson() {
    if (error == null) {
      groupFormed = all['groupFormed'];
      isGroupOwner = all['isGroupOwner'];
      groupOwnerAddress = all['groupOwnerAddress'];
    } else {
      groupFormed = false;
      isGroupOwner = false;
      groupOwnerAddress = '';
    }
  }

  String toJson() => jsonEncode(all);
}
