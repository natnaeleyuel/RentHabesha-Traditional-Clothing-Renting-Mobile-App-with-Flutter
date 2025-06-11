import 'package:flutter/foundation.dart';

import '../utils/network_utils.dart';

class NetworkInfoProvider with ChangeNotifier {
  String? _ipAddress;

  String? get ipAddress => _ipAddress;

  Future<void> fetchIpAddress() async {
    _ipAddress = await NetworkUtils.getDeviceIpAddress();
    notifyListeners();
  }
}

