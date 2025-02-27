import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import 'package:lottie/lottie.dart';

class LotteryCounterWidget extends StatelessWidget {
  final int currentCount;
  final bool isDrawing;

  const LotteryCounterWidget({
    super.key,
    required this.currentCount,
    this.isDrawing = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentCount / AppConfig.ticketQuota;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Draw',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '$currentCount/${AppConfig.ticketQuota}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 20,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (isDrawing) ...[
              const SizedBox(height: 16),
              Center(
                child: Lottie.asset(
                  'assets/animations/lottery-draw.json',
                  width: 100,
                  height: 100,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Drawing in progress...',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}