import 'package:flutter/material.dart';
import '../../../shared/services/lottery_service.dart';
import '../../../shared/services/wallet_service.dart';
import '../../../features/auth/auth_service.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/models/wallet_transaction.dart';

class TicketPurchaseScreen extends StatefulWidget {
  const TicketPurchaseScreen({super.key});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final _lotteryService = LotteryService();
  final _walletService = WalletService();
  final _authService = AuthService();
  bool _isProcessing = false;

  Future<void> _purchaseTicket() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create transaction for ticket purchase
      final transaction = await _walletService.createTransaction(
        userId: userId,
        amount: AppConfig.ticketPrice,
        type: TransactionType.ticketPurchase,
      );

      // Purchase the ticket
      await _lotteryService.purchaseTicket(
        userId: userId,
        price: AppConfig.ticketPrice,
        transactionHash: transaction.transactionHash,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket purchased successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to purchase ticket: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Purchase a lottery ticket to participate in the next draw',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Ticket Price',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppConfig.ticketPrice} USDT',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _purchaseTicket,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Purchase Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}