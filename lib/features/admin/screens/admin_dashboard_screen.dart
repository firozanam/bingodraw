import 'package:flutter/material.dart';
import '../../../shared/services/lottery_service.dart';
import '../../../shared/services/wallet_service.dart';
import '../../../shared/models/lottery_draw.dart';
import '../../../shared/models/wallet_transaction.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _lotteryService = LotteryService();
  final _walletService = WalletService();
  List<LotteryDraw> _pendingDraws = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingDraws();
  }

  Future<void> _loadPendingDraws() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement API call to get pending draws
      setState(() {
        _pendingDraws = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load pending draws');
    }
  }

  Future<void> _processPrizeWithdrawal(LotteryDraw draw) async {
    try {
      setState(() => _isLoading = true);

      // Create withdrawal transaction
      final transaction = await _walletService.createTransaction(
        userId: 'WINNER_USER_ID', // Get from draw
        amount: draw.prizePool,
        type: TransactionType.prizeWithdrawal,
        drawId: draw.id,
      );

      // Process USDT transfer
      final success = await _walletService.processUSDTPayment(
        fromAddress: 'ADMIN_WALLET_ADDRESS',
        toAddress: 'WINNER_WALLET_ADDRESS', // Get from winner
        amount: draw.prizePool,
        transaction: transaction,
      );

      if (success) {
        // Update draw status
        // TODO: Implement API call to update draw status
        
        _showSuccess('Prize withdrawal processed successfully');
        _loadPendingDraws();
      } else {
        _showError('Failed to process withdrawal');
      }
    } catch (e) {
      _showError('Error processing withdrawal: ${e.toString()}');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingDraws,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPendingDraws,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Pending Prize Withdrawals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_pendingDraws.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No pending withdrawals'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pendingDraws.length,
                      itemBuilder: (context, index) {
                        final draw = _pendingDraws[index];
                        return _buildDrawCard(draw);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.confirmation_number,
                  label: 'Total Tickets',
                  value: '0',
                ),
                _buildStatItem(
                  icon: Icons.emoji_events,
                  label: 'Total Draws',
                  value: '0',
                ),
                _buildStatItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Prize Pool',
                  value: '0 USDT',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(label),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildDrawCard(LotteryDraw draw) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Draw #${draw.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${draw.prizePool} USDT',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Winner: ${draw.winningTicketId}'),
            Text('Date: ${_formatDate(draw.drawDate)}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _processPrizeWithdrawal(draw),
                child: const Text('Process Withdrawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}