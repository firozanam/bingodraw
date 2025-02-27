import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_connection_service.dart';
import '../screens/wallet_connection_screen.dart';

class WalletStatusWidget extends StatelessWidget {
  const WalletStatusWidget({super.key});

  String _formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatBalance(BigInt balance) {
    // Convert from wei (18 decimals) to USDT
    final decimals = BigInt.from(10).pow(18);
    final value = balance / decimals;
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletConnectionService>(
      builder: (context, walletService, _) {
        final isConnected = walletService.connectionState == 
            WalletConnectionState.connected;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wallet Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (isConnected)
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: walletService.disconnectWallet,
                        tooltip: 'Disconnect Wallet',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isConnected) ...[
                  Text(
                    'Connected: ${_formatAddress(walletService.connectedAddress!)}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<BigInt>(
                    future: walletService.getUSDTBalance(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 24,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final balance = snapshot.data ?? BigInt.zero;
                      return Text(
                        '${_formatBalance(balance)} USDT',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ] else
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletConnectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Connect Wallet'),
                  ),
                if (walletService.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      walletService.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}