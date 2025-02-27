import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import '../../../shared/services/web3_service.dart';

enum WalletConnectionState {
  disconnected,
  connecting,
  connected,
  error
}

class WalletConnectionService extends ChangeNotifier {
  final Web3Service _web3Service = Web3Service();
  late final SharedPreferences _prefs;
  
  String? _connectedAddress;
  WalletConnectionState _connectionState = WalletConnectionState.disconnected;
  String? _error;

  static final WalletConnectionService _instance = WalletConnectionService._internal();
  factory WalletConnectionService() => _instance;
  
  WalletConnectionService._internal() {
    _initService();
  }

  Future<void> _initService() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedWallet();
  }

  String? get connectedAddress => _connectedAddress;
  WalletConnectionState get connectionState => _connectionState;
  String? get error => _error;

  Future<void> _loadSavedWallet() async {
    final savedAddress = _prefs.getString('wallet_address');
    if (savedAddress != null) {
      await connectWallet(savedAddress);
    }
  }

  Future<BigInt> getUSDTBalance([String? address]) async {
    final walletAddress = address ?? _connectedAddress;
    if (walletAddress == null) {
      throw Exception('No wallet connected');
    }
    return _web3Service.getUSDTBalance(walletAddress);
  }

  Future<bool> connectWallet(String address) async {
    try {
      _connectionState = WalletConnectionState.connecting;
      _error = null;
      notifyListeners();

      // Validate the address
      if (!isValidAddress(address)) {
        throw Exception('Invalid wallet address format');
      }

      // Check if the wallet has USDT balance
      final balance = await _web3Service.getUSDTBalance(address);
      if (balance <= BigInt.zero) {
        throw Exception('Insufficient USDT balance');
      }

      // Save the connected address
      await _prefs.setString('wallet_address', address);

      _connectedAddress = address;
      _connectionState = WalletConnectionState.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _connectionState = WalletConnectionState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnectWallet() async {
    await _prefs.remove('wallet_address');
    _connectedAddress = null;
    _connectionState = WalletConnectionState.disconnected;
    _error = null;
    notifyListeners();
  }

  bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }
}