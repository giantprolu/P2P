import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceName() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // prefixing IDs to avoid ID collision
  String name = '';
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    name = "${androidInfo.manufacturer} ${androidInfo.model}";
  } else {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if (iosInfo.name.isNotEmpty && iosInfo.model.isNotEmpty) {
      name = "${iosInfo.name} ${iosInfo.model}";
    }
  }
  if (name.isEmpty) {
    return "Me";
  }
  return name;
}

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // prefixing IDs to avoid ID collision
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return 'android_${androidInfo.id}';
  } else {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return 'ios_${iosInfo.identifierForVendor}';
  }
}