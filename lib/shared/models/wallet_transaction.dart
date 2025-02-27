enum TransactionType {
  ticketPurchase,
  prizeWithdrawal,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String transactionHash;
  final DateTime timestamp;
  final String? ticketId;
  final String? drawId;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.transactionHash,
    required this.timestamp,
    this.ticketId,
    this.drawId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      transactionHash: json['transactionHash'],
      timestamp: DateTime.parse(json['timestamp']),
      ticketId: json['ticketId'],
      drawId: json['drawId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString(),
      'status': status.toString(),
      'transactionHash': transactionHash,
      'timestamp': timestamp.toIso8601String(),
      'ticketId': ticketId,
      'drawId': drawId,
    };
  }
}