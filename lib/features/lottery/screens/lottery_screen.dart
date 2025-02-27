import 'package:flutter/material.dart';
import '../../../shared/services/lottery_service.dart';
import './ticket_purchase_screen.dart';

class LotteryScreen extends StatelessWidget {
  const LotteryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lotteryService = LotteryService();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<int>(
              stream: lotteryService.ticketCount,
              builder: (context, snapshot) {
                final ticketCount = snapshot.data ?? 0;
                final remainingTickets = 100 - ticketCount;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Current Draw Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: ticketCount / 100,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$ticketCount/100 tickets sold',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '$remainingTickets tickets remaining',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TicketPurchaseScreen(),
                  ),
                );
              },
              child: const Text('Purchase Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}