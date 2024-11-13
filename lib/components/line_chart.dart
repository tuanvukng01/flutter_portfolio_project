// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class CustomLineChart extends StatelessWidget {
//   final List<double> data;
//   final List<String> labels;

//   CustomLineChart({required this.data, required this.labels});

//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         titlesData: FlTitlesData(
//           bottomTitles: SideTitles(
//             showTitles: true,
//             getTitles: (value) {
//               int index = value.toInt();
//               return (index >= 0 && index < labels.length) ? labels[index] : '';
//             },
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//             spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }