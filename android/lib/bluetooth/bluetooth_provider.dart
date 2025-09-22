import 'dart:io';

import 'package:flutter/services.dart';
import 'package:p2p_chat_core/p2p_chat_core.dart';


class BluetoothNetworkProvider extends NetworkProvider {
  static const MethodChannel _channel = MethodChannel('tambapps/bluetooth');
  
  @override
  Future<InternetAddress> getIpAddress() async {
    final String address = await _channel.invokeMethod('getBluetoothAddress');
    return InternetAddress(address);
  }

  @override
  Future<List<NetworkInterface>> listMulticastNetworkInterfaces() async {
    // For Bluetooth PAN, this might not be needed but keeping interface consistent
    return [];
  }

  // Method to scan for Raspberry Pi relay
  Future<List<String>> scanForRelays() async {
    final List<dynamic> devices = await _channel.invokeMethod('scanBluetoothDevices');
    return devices.cast<String>();
  }

  // Method to connect to Raspberry Pi relay
  Future<bool> connectToRelay(String deviceAddress) async {
    return await _channel.invokeMethod('connectToDevice', {'address': deviceAddress});
  }
}