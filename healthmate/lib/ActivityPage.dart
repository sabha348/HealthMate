import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'PedometerService.dart';
import 'GyroscopeCyclingService.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final PedometerService _pedometerService = PedometerService();
  final GyroscopeCyclingService _gyroscopeCyclingService = GyroscopeCyclingService();

  List<int> _footstepsData = List.filled(7, 0);
  List<int> _cyclingStepsData = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _fetchDynamicData();
  }

  Future<void> _fetchDynamicData() async {
    List<int> footsteps = [];
    List<int> cyclingSteps = [];

    for (int i = 0; i < 7; i++) {
      int footstepCount = await _pedometerService.getStepsForDay(i);
      int cyclingCount = await _gyroscopeCyclingService.getCyclingStepsForDay(i);

      footsteps.add(footstepCount);
      cyclingSteps.add(cyclingCount);
    }

    setState(() {
      _footstepsData = footsteps;
      _cyclingStepsData = cyclingSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Last 7 Days Activity',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _buildActivityGraph('Footsteps', _footstepsData),
              const SizedBox(height: 16),
              _buildActivityGraph('Cycling Steps', _cyclingStepsData),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildActivityGraph(String label, List<int> data) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              backgroundColor: Colors.black,
              lineBarsData: [
                LineChartBarData(
                  spots: _buildChartSpots(data),
                  isCurved: true,
                  color: Colors.blue, 
                  barWidth: 4,
                  dotData: FlDotData(show: false), 
                  belowBarData: BarAreaData(
                    show: true,
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'Day ${value.toInt() + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.2), 
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.2), 
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
             //     tooltipBgColor: Colors.grey[800]!,
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toInt()} $label',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildChartSpots(List<int> data) {
    return List.generate(
      data.length,
          (index) => FlSpot(index.toDouble(), data[index].toDouble()),
    );
  }
}

