import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:web3dart/web3dart.dart';
import '../models/wallet_transaction.dart';
import 'web3_service.dart';
import '../../core/config/app_config.dart';

class WalletService {
  final _uuid = const Uuid();
  final Web3Service _web3Service;
  final List<WalletTransaction> _transactions = [];

  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  
  WalletService._internal() : _web3Service = Web3Service();

  Future<WalletTransaction> createTransaction({
    required String userId,
    required double amount,
    required TransactionType type,
    String? ticketId,
    String? drawId,
  }) async {
    final transaction = WalletTransaction(
      id: _uuid.v4(),
      userId: userId,
      amount: amount,
      type: type,
      status: TransactionStatus.pending,
      transactionHash: '',
      timestamp: DateTime.now(),
      ticketId: ticketId,
      drawId: drawId,
    );

    _transactions.add(transaction);
    return transaction;
  }

  // Convert BigInt balance to double by handling USDT decimal places
  double _convertUSDTBalance(BigInt balance) {
    final decimals = BigInt.from(10).pow(18); // USDT uses 18 decimals
    final whole = balance ~/ decimals;
    final fraction = balance % decimals;
    
    return whole.toDouble() + (fraction.toDouble() / decimals.toDouble());
  }

  Future<bool> processUSDTPayment({
    required String fromAddress,
    required String toAddress,
    required double amount,
    required WalletTransaction transaction,
  }) async {
    try {
      // Convert amount to proper decimals (USDT uses 18 decimals)
      final amountInWei = BigInt.from(amount * 1e18);
      
      // TODO: Get credentials from secure storage or wallet connection
      final credentials = EthPrivateKey.fromHex('your-private-key');
      
      // Send USDT transfer transaction
      final txHash = await _web3Service.transferUSDT(
        credentials: credentials,
        to: toAddress,
        amount: amountInWei,
      );

      // Wait for transaction confirmation
      TransactionReceipt? receipt;
      int attempts = 0;
      while (receipt == null && attempts < 30) {
        receipt = await _web3Service.getTransactionReceipt(txHash);
        if (receipt == null) {
          await Future.delayed(const Duration(seconds: 2));
          attempts++;
        }
      }

      if (receipt != null && receipt.status!) {
        // Update transaction status
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = WalletTransaction(
            id: transaction.id,
            userId: transaction.userId,
            amount: transaction.amount,
            type: transaction.type,
            status: TransactionStatus.completed,
            transactionHash: txHash,
            timestamp: transaction.timestamp,
            ticketId: transaction.ticketId,
            drawId: transaction.drawId,
          );
        }
        return true;
      }
      
      throw Exception('Transaction failed');
    } catch (e) {
      // Update transaction status to failed
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = WalletTransaction(
          id: transaction.id,
          userId: transaction.userId,
          amount: transaction.amount,
          type: transaction.type,
          status: TransactionStatus.failed,
          transactionHash: '',
          timestamp: transaction.timestamp,
          ticketId: transaction.ticketId,
          drawId: transaction.drawId,
        );
      }
      return false;
    }
  }

  Future<List<WalletTransaction>> getUserTransactions(String userId) async {
    return _transactions.where((t) => t.userId == userId).toList();
  }

  Future<double> getUserBalance(String address) async {
    try {
      final balance = await _web3Service.getUSDTBalance(address);
      return _convertUSDTBalance(balance);
    } catch (e) {
      return 0.0;
    }
  }
}