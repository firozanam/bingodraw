import 'package:lottery/shared/models/ticket.dart';
import 'package:hive/hive.dart';

part 'lottery_draw.g.dart';

@HiveType(typeId: 0)
enum DrawStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  failed
}

@HiveType(typeId: 1)
class LotteryDraw extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime drawDate;

  @HiveField(2)
  final String winningTicketId;

  @HiveField(3)
  final double prizePool;

  @HiveField(4)
  final int totalTickets;

  @HiveField(5)
  final int blockNumber;

  @HiveField(6)
  final String blockHash;

  @HiveField(7)
  final String verifiableHash;

  @HiveField(8)
  DrawStatus status;

  LotteryDraw({
    required this.id,
    required this.drawDate,
    required this.winningTicketId,
    required this.prizePool,
    required this.totalTickets,
    required this.blockNumber,
    required this.blockHash,
    required this.verifiableHash,
    required this.status,
  });
}