import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import '../../core/config/app_config.dart';

class Web3Service {
  late final Web3Client _client;
  
  // Singleton pattern
  static final Web3Service _instance = Web3Service._internal();
  factory Web3Service() => _instance;
  
  Web3Service._internal() {
    final httpClient = Client();
    _client = Web3Client(AppConfig.rpcUrl, httpClient);
  }

  Future<BigInt> getUSDTBalance(String address) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(AppConfig.usdtAbi, 'USDT'),
      EthereumAddress.fromHex(AppConfig.usdtContractAddress),
    );

    final balanceFunction = contract.function('balanceOf');
    final balance = await _client.call(
      contract: contract,
      function: balanceFunction,
      params: [EthereumAddress.fromHex(address)],
    );

    return balance.first as BigInt;
  }

  Future<String> transferUSDT({
    required Credentials credentials,
    required String to,
    required BigInt amount,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(AppConfig.usdtAbi, 'USDT'),
      EthereumAddress.fromHex(AppConfig.usdtContractAddress),
    );

    final transferFunction = contract.function('transfer');
    final transaction = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transferFunction,
        parameters: [EthereumAddress.fromHex(to), amount],
      ),
      chainId: AppConfig.binanceNetwork == 'mainnet' ? 56 : 97,
    );

    return transaction;
  }

  Future<int> getLatestBlockNumber() async {
    try {
      final blockNumber = await _client.getBlockNumber();
      return blockNumber.toInt();
    } catch (e) {
      print('Error getting latest block number: $e');
      throw Exception('Failed to get latest block number');
    }
  }

  Future<String> getLatestBlockHash() async {
    final blockNumber = await _client.getBlockNumber();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Create a deterministic hash using block number and timestamp
    final input = utf8.encode('$blockNumber:$timestamp');
    final hash = sha256.convert(input);
    return '0x${hash.toString()}';
  }

  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await _client.getTransactionReceipt(txHash);
  }

  Future<void> close() async {
    _client.dispose();
  }
}