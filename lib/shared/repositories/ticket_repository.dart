import 'package:hive_flutter/hive_flutter.dart';
import '../models/ticket.dart';

class TicketRepository {
  static const String _boxName = 'tickets';
  late Box<Ticket> _ticketBox;
  
  static final TicketRepository _instance = TicketRepository._internal();
  factory TicketRepository() => _instance;
  
  TicketRepository._internal();

  Future<void> initialize() async {
    // Register the Ticket adapter
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TicketAdapter());
      Hive.registerAdapter(TicketStatusAdapter());
    }
    
    _ticketBox = await Hive.openBox<Ticket>(_boxName);
  }

  Future<void> saveTicket(Ticket ticket) async {
    await _ticketBox.put(ticket.id, ticket);
  }

  Future<void> saveTickets(List<Ticket> tickets) async {
    final ticketsMap = {for (var ticket in tickets) ticket.id: ticket};
    await _ticketBox.putAll(ticketsMap);
  }

  Future<List<Ticket>> getAllTickets() async {
    return _ticketBox.values.toList();
  }

  Future<List<Ticket>> getActiveTickets() async {
    return _ticketBox.values
        .where((ticket) => ticket.status == TicketStatus.active)
        .toList();
  }

  Future<List<Ticket>> getUserTickets(String userId) async {
    return _ticketBox.values
        .where((ticket) => ticket.userId == userId)
        .toList();
  }

  Future<Ticket?> getTicket(String id) async {
    return _ticketBox.get(id);
  }

  Future<void> updateTicketStatus(String id, TicketStatus status) async {
    final ticket = await getTicket(id);
    if (ticket != null) {
      ticket.status = status;
      await saveTicket(ticket);
    }
  }

  Future<int> getActiveTicketCount() async {
    return (await getActiveTickets()).length;
  }

  Future<void> close() async {
    await _ticketBox.close();
  }
}