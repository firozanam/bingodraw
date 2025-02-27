import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/ticket.dart';
import '../models/lottery_draw.dart';
import '../models/wallet_transaction.dart';
import '../../core/config/app_config.dart';
import '../repositories/ticket_repository.dart';

class LotteryService {
  final _uuid = const Uuid();
  final TicketRepository _ticketRepository;
  final _ticketCountController = StreamController<int>.broadcast();

  static final LotteryService _instance = LotteryService._internal();
  factory LotteryService() => _instance;

  LotteryService._internal() : _ticketRepository = TicketRepository() {
    _startTicketCountUpdates();
  }

  void _startTicketCountUpdates() {
    Timer.periodic(const Duration(seconds: 10), (_) async {
      final count = await getActiveTicketCount();
      _ticketCountController.add(count);
    });
  }

  Stream<int> get ticketCount => _ticketCountController.stream;

  Future<Ticket> purchaseTicket({
    required String userId,
    required double price,
    required String transactionHash,
  }) async {
    final ticket = Ticket(
      id: _uuid.v4(),
      userId: userId,
      price: price,
      purchaseDate: DateTime.now(),
      transactionHash: transactionHash,
    );

    await _ticketRepository.saveTicket(ticket);
    final count = await getActiveTicketCount();
    _ticketCountController.add(count);
    return ticket;
  }

  Future<List<Ticket>> getUserTickets(String userId) async {
    return _ticketRepository.getUserTickets(userId);
  }

  Future<List<Ticket>> getActiveTickets() async {
    return _ticketRepository.getActiveTickets();
  }

  Future<int> getActiveTicketCount() async {
    return _ticketRepository.getActiveTicketCount();
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required bool isWinner,
    required TicketStatus status,
  }) async {
    final ticket = await _ticketRepository.getTicket(ticketId);
    if (ticket != null) {
      ticket.isWinner = isWinner;
      ticket.status = status;
      await _ticketRepository.saveTicket(ticket);
      final count = await getActiveTicketCount();
      _ticketCountController.add(count);
    }
  }

  void dispose() {
    _ticketCountController.close();
  }
}