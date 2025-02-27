import 'package:flutter/material.dart';
import '../../../shared/models/ticket.dart';
import '../../../shared/services/lottery_service.dart';
import '../../../shared/widgets/lottery_ticket_widget.dart';
import '../../../features/auth/auth_service.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lotteryService = LotteryService();
    final userId = AuthService().currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Please sign in to view your tickets'));
    }

    return StreamBuilder<List<Ticket>>(
      stream: Stream.fromFuture(lotteryService.getUserTickets(userId)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tickets yet',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Purchase a ticket to participate in the lottery',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LotteryTicketWidget(ticket: ticket),
            );
          },
        );
      },
    );
  }
}