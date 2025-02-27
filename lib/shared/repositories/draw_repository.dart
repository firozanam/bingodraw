import 'package:hive_flutter/hive_flutter.dart';
import '../models/lottery_draw.dart';

class DrawRepository {
  static const String _boxName = 'draws';
  late Box<LotteryDraw> _drawBox;
  
  static final DrawRepository _instance = DrawRepository._internal();
  factory DrawRepository() => _instance;
  
  DrawRepository._internal();

  Future<void> initialize() async {
    // Register the LotteryDraw adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LotteryDrawAdapter());
      Hive.registerAdapter(DrawStatusAdapter());
    }
    
    _drawBox = await Hive.openBox<LotteryDraw>(_boxName);
  }

  Future<void> saveDraw(LotteryDraw draw) async {
    await _drawBox.put(draw.id, draw);
  }

  Future<List<LotteryDraw>> getAllDraws() async {
    return _drawBox.values.toList()
      ..sort((a, b) => b.drawDate.compareTo(a.drawDate));
  }

  Future<LotteryDraw?> getDraw(String id) async {
    return _drawBox.get(id);
  }

  Future<void> updateDrawStatus(String id, DrawStatus status) async {
    final draw = await getDraw(id);
    if (draw != null) {
      draw.status = status;
      await saveDraw(draw);
    }
  }

  Future<void> close() async {
    await _drawBox.close();
  }
}