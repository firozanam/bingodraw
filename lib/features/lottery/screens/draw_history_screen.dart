import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/lottery_draw.dart';
import '../../../shared/services/lottery_draw_service.dart';
import '../../../core/config/app_config.dart';

class DrawHistoryScreen extends StatefulWidget {
  const DrawHistoryScreen({super.key});

  @override
  State<DrawHistoryScreen> createState() => _DrawHistoryScreenState();
}

class _DrawHistoryScreenState extends State<DrawHistoryScreen> {
  final _drawService = LotteryDrawService();
  List<LotteryDraw> _draws = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDrawHistory();
    _subscribeToDrawUpdates();
  }

  void _subscribeToDrawUpdates() {
    _drawService.drawUpdates.listen((draw) {
      setState(() {
        _draws = [draw, ..._draws];
      });
    });
  }

  Future<void> _loadDrawHistory() async {
    setState(() => _isLoading = true);
    try {
      final draws = await _drawService.getDrawHistory();
      setState(() {
        _draws = draws;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load draw history');
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

  Future<void> _openBlockExplorer(String blockHash) async {
    final url = Uri.parse('${AppConfig.explorerUrl}/block/$blockHash');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showError('Could not open block explorer');
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
        title: const Text('Draw History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrawHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDrawHistory,
              child: _draws.isEmpty
                  ? const Center(
                      child: Text('No draws yet'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _draws.length,
                      itemBuilder: (context, index) {
                        final draw = _draws[index];
                        return _buildDrawCard(draw);
                      },
                    ),
            ),
    );
  }

  Widget _buildDrawCard(LotteryDraw draw) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: Text('Draw #${draw.id.substring(0, 8)}'),
        subtitle: Text(_formatDate(draw.drawDate)),
        trailing: Text(
          '${draw.prizePool} USDT',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Total Tickets', draw.totalTickets.toString()),
                _buildInfoRow('Status', draw.status.toString().split('.').last),
                _buildInfoRow(
                  'Winning Ticket',
                  draw.winningTicketId.substring(0, 16) + '...',
                ),
                const SizedBox(height: 8),
                const Divider(),
                const Text(
                  'Verification Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHashRow(
                  'Block Hash',
                  draw.blockHash,
                  onTap: () => _openBlockExplorer(draw.blockHash),
                ),
                _buildInfoRow('Block Number', draw.blockNumber.toString()),
                _buildHashRow(
                  'Verifiable Hash',
                  draw.verifiableHash,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: draw.verifiableHash));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hash copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  '${value.substring(0, 10)}...',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  onTap == _openBlockExplorer
                      ? Icons.open_in_new
                      : Icons.copy,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}