import 'dart:io';

import 'package:p2p_chat_core/src/network.dart';

class TestNetworkProvider implements NetworkProvider {
  final InternetAddress address;

  TestNetworkProvider(this.address);

  @override
  Future<InternetAddress> getIpAddress() async {
    return address;
  }

  @override
  Future<List<NetworkInterface>> listMulticastNetworkInterfaces() async {
    // For testing purposes, return an empty list as we don't need multicast in tests
    return [];
  }
}