import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/services/wallet_service.dart';
import '../../../shared/models/wallet_transaction.dart';
import '../../auth/auth_service.dart';
import '../widgets/transaction_details_dialog.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _walletService = WalletService();
  final _authService = AuthService();
  List<WalletTransaction> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (_authService.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final transactions = await _walletService.getUserTransactions(
        _authService.currentUser!.uid,
      );
      setState(() {
        _transactions = transactions..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    } catch (e) {
      _showError('Failed to load transactions');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _showTransactionDetails(WalletTransaction transaction) async {
    await showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        transaction: transaction,
      ),
    );
  }

  Future<void> _openTransactionOnBscScan(String txHash) async {
    final url = Uri.parse('https://bscscan.com/tx/$txHash');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showError('Could not open transaction on BscScan');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: _transactions.isEmpty
                  ? const Center(
                      child: Text('No transactions yet'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
            ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        child: ListTile(
          leading: Icon(
            transaction.type == TransactionType.ticketPurchase
                ? Icons.confirmation_number
                : Icons.emoji_events,
            color: transaction.status == TransactionStatus.completed
                ? Colors.green
                : transaction.status == TransactionStatus.failed
                    ? Colors.red
                    : Colors.orange,
          ),
          title: Text(
            transaction.type == TransactionType.ticketPurchase
                ? 'Ticket Purchase'
                : 'Prize Withdrawal',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(transaction.timestamp)),
              if (transaction.transactionHash.isNotEmpty)
                InkWell(
                  onTap: () => _openTransactionOnBscScan(transaction.transactionHash),
                  child: Text(
                    'TX: ${transaction.transactionHash.substring(0, 10)}...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.type == TransactionType.ticketPurchase ? '-' : '+'}'
                '${transaction.amount} USDT',
                style: TextStyle(
                  color: transaction.type == TransactionType.ticketPurchase
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transaction.status.toString().split('.').last,
                style: TextStyle(
                  color: transaction.status == TransactionStatus.completed
                      ? Colors.green
                      : transaction.status == TransactionStatus.failed
                          ? Colors.red
                          : Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}