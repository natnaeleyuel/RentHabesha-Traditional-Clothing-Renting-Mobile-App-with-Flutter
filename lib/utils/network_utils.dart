import 'package:network_info_plus/network_info_plus.dart';

class NetworkUtils {
  static final NetworkInfo _networkInfo = NetworkInfo();

  static Future<String?> getDeviceIpAddress() async {
    try {
      final wifiIp = await _networkInfo.getWifiIP();

      return wifiIp ?? await _networkInfo.getWifiGatewayIP();
    } catch (e) {
      print('Error getting IP address: $e');
      return null;
    }
  }
}