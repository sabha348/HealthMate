import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityChartPage extends StatelessWidget {
  final List<Map<String, dynamic>> data; 

  const ActivityChartPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Chart')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Activity Breakdown (Last 7 Days)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _getBarChartGroups(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.5, 
                              child: Text(
                                data[value.toInt()]['date'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 500, 
                        getTitlesWidget: (value, _) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true, 
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 0.5,
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String activityType = rod.color == Colors.blue ? 'Walking' : 'Cycling';
                        return BarTooltipItem(
                          '$activityType\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: rod.toY.toString(),
                              style: const TextStyle(color: Colors.yellow),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(), 
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarChartGroups() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      double walking = entry.value['walking'].toDouble();
      double cycling = entry.value['cycling'].toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: walking,
            color: Colors.blue, 
            width: 12, 
            borderRadius: BorderRadius.circular(6),
          ),
          BarChartRodData(
            toY: cycling,
            color: Colors.orange, 
            width: 12, 
            borderRadius: BorderRadius.circular(6),
          ),
        ],
        barsSpace: 8,
        showingTooltipIndicators: [0, 1],
      );
    }).toList();
  }

  
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.blue, 'Walking'),
        _buildLegendItem(Colors.orange, 'Cycling'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
