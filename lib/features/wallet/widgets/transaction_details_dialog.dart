import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/wallet_transaction.dart';
import '../../../core/config/app_config.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionDetailsDialog({
    super.key,
    required this.transaction,
  });

  Future<void> _openExplorer() async {
    final networkPrefix = AppConfig.binanceNetwork == 'mainnet' ? '' : 'testnet.';
    final url = 'https://${networkPrefix}bscscan.com/tx/${transaction.transactionHash}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transaction Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Amount'),
            subtitle: Text('${transaction.amount} USDT'),
          ),
          ListTile(
            title: const Text('Type'),
            subtitle: Text(transaction.type.toString().split('.').last),
          ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(transaction.status.toString().split('.').last),
          ),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(transaction.timestamp.toString()),
          ),
          if (transaction.transactionHash.isNotEmpty)
            ListTile(
              title: const Text('View on Explorer'),
              trailing: const Icon(Icons.open_in_new),
              onTap: _openExplorer,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}