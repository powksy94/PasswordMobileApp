import 'package:flutter/material.dart';
import '../../utils/password_score.dart';
import '../common/glass_panel.dart';

class HealthScoreCard extends StatelessWidget {
  final int score;
  final int total;
  final int strongCount;
  final int weakCount;
  final int dupCount;

  const HealthScoreCard({
    super.key,
    required this.score,
    required this.total,
    required this.strongCount,
    required this.weakCount,
    required this.dupCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = PasswordScore.color(score);

    return GlassPanel(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Score global',
            style: TextStyle(
              color:    isDark ? Colors.white54 : Colors.black45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / 100',
            style: TextStyle(
              fontSize:   48,
              fontWeight: FontWeight.bold,
              color:      color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           score / 100,
              backgroundColor: Colors.white12,
              color:           color,
              minHeight:       8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat('$total',       'Total',    color),
              _Stat('$strongCount', 'Forts',    Colors.cyanAccent),
              _Stat('$weakCount',   'Faibles',  Colors.redAccent),
              _Stat('$dupCount',    'Doublons', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;

  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color:      color,
            fontSize:   22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color:    color.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
