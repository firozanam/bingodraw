import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/ticket.dart';
import '../../../core/config/app_config.dart';

class TicketDetailsDialog extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsDialog({
    super.key,
    required this.ticket,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}';
  }

  Future<void> _openTransactionOnBscScan(BuildContext context) async {
    if (ticket.transactionHash == null) return;
    
    final networkPrefix = AppConfig.binanceNetwork == 'mainnet' ? '' : 'testnet.';
    final url = Uri.parse('https://${networkPrefix}bscscan.com/tx/${ticket.transactionHash}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.active:
        return Colors.blue;
      case TicketStatus.won:
        return Colors.green;
      case TicketStatus.lost:
        return Colors.red;
      case TicketStatus.expired:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow(
              context,
              'Ticket ID',
              ticket.id,
            ),
            _buildDetailRow(
              context,
              'Price',
              '${ticket.price} USDT',
            ),
            _buildDetailRow(
              context,
              'Purchase Date',
              _formatDate(ticket.purchaseDate),
            ),
            _buildDetailRow(
              context,
              'Status',
              ticket.status.toString().split('.').last,
              color: _getStatusColor(ticket.status),
            ),
            if (ticket.transactionHash != null)
              _buildHashRow(
                context,
                'Transaction',
                ticket.transactionHash!,
              ),
            if (ticket.drawId != null)
              _buildDetailRow(
                context,
                'Draw ID',
                ticket.drawId!,
              ),
            const SizedBox(height: 16),
            if (ticket.status == TicketStatus.active)
              Center(
                child: Text(
                  'Drawing will occur when ${AppConfig.ticketQuota} tickets are sold',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (ticket.transactionHash != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _openTransactionOnBscScan(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Transaction'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: color != null ? TextStyle(color: color) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hash copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(Icons.copy, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}