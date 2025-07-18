import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Widget buildChart() {
  final user = FirebaseAuth.instance.currentUser;
  final userId = user!.uid;

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('items')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final expiryMap = getExpiryCounts(snapshot.data!.docs);
      final barCount = expiryMap.length;
      const double barWidth = 16;
      const double barSpacing = 40;
      final chartWidth = barCount * (barWidth + barSpacing) + 100;

      return Scaffold(
        appBar: AppBar(
          title: const Text("Expiry Chart"),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Expiry Overview",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Bars show number of items expiring in different timeframes.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _buildBarChart(expiryMap),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildBarChart(Map<String, int> expiryMap) {
  final barGroups = expiryMap.entries.toList().asMap().entries.map((entry) {
    final index = entry.key;
    final label = entry.value.key; //can unserstand the difference
    final count = entry.value.value;

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          gradient: LinearGradient(
            colors: [Colors.pink.shade400, Colors.pink.shade200],
          ),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }).toList();

  return BarChart(
  BarChartData(
    maxY: (expiryMap.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
    barGroups: barGroups,
    borderData: FlBorderData(show: false),
    gridData: const FlGridData(show: false),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 20, 
          interval: 1,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            final labels = expiryMap.keys.toList();
            if (value.toInt() >= 0 && value.toInt() < labels.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  labels[value.toInt()],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
    ),
    barTouchData: BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.black,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final label = expiryMap.keys.toList()[group.x.toInt()];
          return BarTooltipItem(
            '$label: ${rod.toY.toInt()} items',
            const TextStyle(color: Colors.white),
          );
        },
      ),
    ),
  ),
);

}

int getExpiringSoonCount(List<QueryDocumentSnapshot> docs) {
  final now = DateTime.now();
  final in7Days = now.add(const Duration(days: 7));

  return docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    final expiry = DateTime.parse(data['expiryDate']);
    return expiry.isAfter(now) && expiry.isBefore(in7Days);
  }).length;
}

Map<String, int> getExpiryCounts(List<QueryDocumentSnapshot> docs) {
  Map<String, int> counts = {};

  for (var doc in docs) {
    final data = doc.data() as Map<String, dynamic>;
    final expiry = DateTime.parse(data['expiryDate']);
    final formattedDate =
        "${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}";

    counts[formattedDate] = (counts[formattedDate] ?? 0) + 1;
  }

  return counts;
}