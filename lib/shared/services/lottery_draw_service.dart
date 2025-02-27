import 'dart:async';
import '../models/lottery_draw.dart';
import '../models/ticket.dart';
import '../repositories/draw_repository.dart';
import 'lottery_service.dart';
import 'wallet_service.dart';
import 'web3_service.dart';
import '../../core/utils/random_util.dart';
import '../../core/config/app_config.dart';

class LotteryDrawService {
  final LotteryService _lotteryService;
  final WalletService _walletService;
  final Web3Service _web3Service;
  final DrawRepository _drawRepository;
  final StreamController<LotteryDraw> _drawController;
  Timer? _drawTimer;

  static final LotteryDrawService _instance = LotteryDrawService._internal();
  factory LotteryDrawService() => _instance;

  LotteryDrawService._internal()
      : _lotteryService = LotteryService(),
        _walletService = WalletService(),
        _web3Service = Web3Service(),
        _drawRepository = DrawRepository(),
        _drawController = StreamController<LotteryDraw>.broadcast() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _drawRepository.initialize();
    _startDrawMonitoring();
  }

  Stream<LotteryDraw> get drawUpdates => _drawController.stream;

  void _startDrawMonitoring() {
    // Check for draw conditions every minute
    _drawTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDrawConditions();
    });
  }

  Future<void> _checkDrawConditions() async {
    try {
      final ticketCount = await _lotteryService.getCurrentTicketCount();
      if (ticketCount >= AppConfig.ticketQuota) {
        await _performDraw();
      }
    } catch (e) {
      print('Error checking draw conditions: $e');
    }
  }

  Future<void> _performDraw() async {
    try {
      // Get all active tickets
      final tickets = await _lotteryService.getActiveTickets();
      if (tickets.isEmpty) return;

      // Generate verifiable random number using block data
      final blockNumber = await _getLatestBlockNumber();
      final blockHash = await _getBlockHash(blockNumber);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final verifiableHash = RandomUtil.generateVerifiableHash(
        blockNumber,
        blockHash,
        timestamp,
      );

      // Select winner
      final winnerIndex = RandomUtil.selectWinner(
        tickets.length,
        verifiableHash,
      );
      final winningTicket = tickets[winnerIndex];

      // Calculate prize pool
      final prizePool = tickets.length * AppConfig.ticketPrice;

      // Create draw record
      final draw = LotteryDraw(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        drawDate: DateTime.now(),
        winningTicketId: winningTicket.id,
        prizePool: prizePool,
        totalTickets: tickets.length,
        blockNumber: blockNumber,
        blockHash: blockHash,
        verifiableHash: verifiableHash,
        status: DrawStatus.pending,
      );

      // Save draw and update ticket statuses
      await _saveDraw(draw);
      await _updateTicketStatuses(tickets, winningTicket.id);

      // Create prize transaction
      await _createPrizeTransaction(winningTicket, prizePool);

      // Notify listeners
      _drawController.add(draw);
    } catch (e) {
      print('Error performing draw: $e');
    }
  }

  Future<int> _getLatestBlockNumber() async {
    try {
      final blockNumber = await _web3Service.getLatestBlockNumber();
      return blockNumber;
    } catch (e) {
      print('Error getting latest block number: $e');
      throw Exception('Failed to get latest block number');
    }
  }

  Future<String> _getBlockHash(int blockNumber) async {
    try {
      final blockHash = await _web3Service.getBlockHash(blockNumber);
      return blockHash;
    } catch (e) {
      print('Error getting block hash: $e');
      throw Exception('Failed to get block hash');
    }
  }

  Future<void> _saveDraw(LotteryDraw draw) async {
    try {
      await _drawRepository.saveDraw(draw);
    } catch (e) {
      print('Error saving draw: $e');
      throw Exception('Failed to save draw');
    }
  }

  Future<void> _updateTicketStatuses(List<Ticket> tickets, String winningTicketId) async {
    try {
      for (final ticket in tickets) {
        final isWinner = ticket.id == winningTicketId;
        await _lotteryService.updateTicketStatus(
          ticketId: ticket.id,
          isWinner: isWinner,
          status: isWinner ? TicketStatus.won : TicketStatus.lost,
        );
      }
    } catch (e) {
      print('Error updating ticket statuses: $e');
      throw Exception('Failed to update ticket statuses');
    }
  }

  Future<List<LotteryDraw>> getDrawHistory() async {
    return _drawRepository.getAllDraws();
  }

  Future<void> _createPrizeTransaction(Ticket winningTicket, double prizeAmount) async {
    await _walletService.createTransaction(
      userId: winningTicket.userId,
      amount: prizeAmount,
      type: TransactionType.prizeWithdrawal,
      ticketId: winningTicket.id,
    );
  }

  void dispose() {
    _drawTimer?.cancel();
    _drawController.close();
    _drawRepository.close();
  }
}