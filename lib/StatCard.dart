import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final double maxValue;
  final Color color;
  final IconData icon;
  final String? unit;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ✅ Animated Progress Bar
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 800),
              builder: (context, animatedValue, child) {
                double progress = (animatedValue / maxValue).clamp(0.0, 1.0);
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      color: color,
                      backgroundColor: Colors.grey.shade300,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${animatedValue.toStringAsFixed(1)} ${unit ?? ""}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
