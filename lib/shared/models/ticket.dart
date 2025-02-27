import 'package:hive/hive.dart';

part 'ticket.g.dart';

@HiveType(typeId: 1)
class Ticket {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final DateTime purchaseDate;

  @HiveField(4)
  TicketStatus status;

  @HiveField(5)
  String transactionHash;

  @HiveField(6)
  String? drawId;

  @HiveField(7)
  bool isWinner;

  Ticket({
    required this.id,
    required this.userId,
    required this.price,
    required this.purchaseDate,
    this.status = TicketStatus.active,
    required this.transactionHash,
    this.drawId,
    this.isWinner = false,
  });

  // Helper method to create a pending ticket
  factory Ticket.pending({
    required String id,
    required String userId,
    required double price,
  }) {
    return Ticket(
      id: id,
      userId: userId,
      price: price,
      purchaseDate: DateTime.now(),
      status: TicketStatus.active,
      transactionHash: '', // Empty string for pending transactions
    );
  }
}

@HiveType(typeId: 2)
enum TicketStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  won,
  @HiveField(2)
  lost,
  @HiveField(3)
  expired,
}