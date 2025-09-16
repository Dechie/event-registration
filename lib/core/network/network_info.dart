// core/network/network_info.dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  //Future<bool> get isConnected => connectionChecker.hasConnection;
  Future<bool> get isConnected async {
    await Future.delayed(Duration.zero);

    return true;
  }
}
