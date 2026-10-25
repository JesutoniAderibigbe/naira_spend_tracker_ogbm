import 'package:flutter/material.dart';

/// A rounded progress bar. Decorative: callers state the value in words.
class ProgressTrack extends StatelessWidget {
  const ProgressTrack({
    super.key,
    required this.fraction,
    required this.color,
    required this.trackColor,
    this.height = 10,
  });

  /// 0 to 1.
  final double fraction;
  final Color color;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: ColoredBox(
            color: trackColor,
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
