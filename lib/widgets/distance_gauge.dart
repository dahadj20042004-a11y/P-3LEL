// lib/widgets/distance_gauge.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class DistanceGauge extends StatelessWidget {
  final double? distance; // null = no reading yet
  final int warningThreshold;
  final int dangerThreshold;

  const DistanceGauge({
    super.key,
    required this.distance,
    required this.warningThreshold,
    required this.dangerThreshold,
  });

  Color _gaugeColor() {
    if (distance == null) return Colors.grey;
    if (distance! <= dangerThreshold) return AppTheme.dangerRed;
    if (distance! <= warningThreshold) return AppTheme.warningYellow;
    return AppTheme.safeGreen;
  }

  String _statusLabel() {
    if (distance == null) return 'No Signal';
    if (distance! <= dangerThreshold) return 'DANGER';
    if (distance! <= warningThreshold) return 'WARNING';
    return 'SAFE';
  }

  double _progressValue() {
    if (distance == null) return 0;
    const maxDist = 200.0;
    return (distance! / maxDist).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final color = _gaugeColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'OBSTACLE DISTANCE',
              style: TextStyle(
                color: Color(0xFF90A490),
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withAlpha(120), width: 1),
              ),
              child: Text(
                _statusLabel(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Segmented color bar
                  Stack(
                    children: [
                      // Track
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      // Filled portion
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 300),
                        widthFactor: _progressValue(),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(100),
                                blurRadius: 6,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Threshold markers
                  LayoutBuilder(builder: (context, constraints) {
                    const maxD = 200.0;
                    final dPos =
                        (dangerThreshold / maxD) * constraints.maxWidth;
                    final wPos =
                        (warningThreshold / maxD) * constraints.maxWidth;
                    return SizedBox(
                      height: 18,
                      child: Stack(
                        children: [
                          // Danger marker
                          Positioned(
                            left: dPos - 1,
                            child: Container(
                              width: 2,
                              height: 10,
                              color: AppTheme.dangerRed.withAlpha(180),
                            ),
                          ),
                          // Warning marker
                          Positioned(
                            left: wPos - 1,
                            child: Container(
                              width: 2,
                              height: 10,
                              color: AppTheme.warningYellow.withAlpha(180),
                            ),
                          ),
                          Positioned(
                            left: (dPos - 12).clamp(0, double.infinity),
                            top: 11,
                            child: Text(
                              '${dangerThreshold}cm',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.dangerRed.withAlpha(200),
                              ),
                            ),
                          ),
                          Positioned(
                            left: (wPos - 12).clamp(0, double.infinity),
                            top: 11,
                            child: Text(
                              '${warningThreshold}cm',
                              style: TextStyle(
                                fontSize: 9,
                                color:
                                    AppTheme.warningYellow.withAlpha(200),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Distance readout
            Container(
              width: 72,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Column(
                children: [
                  Text(
                    distance != null
                        ? distance!.toStringAsFixed(1)
                        : '---',
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'cm',
                    style: TextStyle(
                      color: color.withAlpha(180),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
