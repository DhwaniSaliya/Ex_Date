import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; //for getting current user
import 'package:flutter/material.dart'; //core widgets
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';

Widget buildPieChart() {
  final user = FirebaseAuth.instance.currentUser;
  final userId = user!.uid; //extract user id

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('items') //listen to user's items
        .snapshots(), //live updates from firestore
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No data available to show"));
      }

      final docs = snapshot.data!.docs;
      int expired = 0, notExpired = 0;
      final now = DateTime.now();
      //we are traversing the docs list to count the no. of expired and non-expired items
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expiry = DateTime.parse(data['expiryDate']); //parse expDate from firestore
        if (expiry.isBefore(now)) {
          expired++;
        } else {
          notExpired++;
        }
      }

      final data = [
        _ChartData('Expired', expired),
        _ChartData('Not Expired', notExpired),
      ];

      return Scaffold(
        appBar: AppBar(
          title: const Text('Expiry Status Overview'),
        ),
        body: Center(
          child: SfCircularChart(
            title: const ChartTitle(
              text: 'Items Expiry Analysis',
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Georgia',
              ),
            ),
            legend: const Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              position: LegendPosition.bottom,
            ),
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    Text(
                      '${expired + notExpired}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              )
            ],
            series: <PieSeries<_ChartData, String>>[
              PieSeries<_ChartData, String>(
                dataSource: data, //pass in expired and not expired values
                xValueMapper: (_ChartData d, _) => d.label,
                yValueMapper: (_ChartData d, _) => d.value,
                explode: true, //highlight the first slice
                explodeIndex: 0,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(fontSize: 12),
                ),
                pointColorMapper: (_ChartData d, _) => d.label == 'Expired'
                    ? Theme.of(context).colorScheme.primaryFixedDim
                    : Theme.of(context).colorScheme.secondaryFixed,
              )
            ],
          ),
        ),
      );
    },
  );
}

//a model for holding data passed to pie chart
class _ChartData {
  final String label;
  final int value;
  _ChartData(this.label, this.value);
}

Widget buildProgressRing(DateTime expiryDate) {
  final now = DateTime.now();
  final totalDuration = expiryDate.difference(now).inDays + 1;
  // Percentage of time passed out of a 30-day window
  final percentage =
      totalDuration > 0 ? (1 - (totalDuration / 30)).clamp(0.0, 1.0) : 1.0;

  return CircularPercentIndicator(
    radius: 60.0,
    lineWidth: 8.0,
    percent: percentage,
    center: Text("${(percentage * 100).toStringAsFixed(1)}%"),
    progressColor: percentage < 0.5
        ? Colors.green
        : (percentage < 0.8 ? Colors.orange : Colors.red),
    footer: totalDuration == 1
        ? Text('Expires in $totalDuration day')
        : (percentage == 1
            ? const Text('Expired!')
            : Text('Expires in $totalDuration days')),
  );
}

//tracks the days remaining for the expiry
Widget buildProgressLine(DateTime expiryDate) {
  final now = DateTime.now();
  //total days remaining to expire
  final totalDuration = expiryDate.difference(now).inDays + 1;
  //converting to percentage acc. to below condition
  //if remaining duration is >=30 then percent of days remaining will be considered 0 and hence no filler would be filled in the pipe.
  //the condition is assumed by me, you can adjust according to your wishes
  final percentage =
      totalDuration > 0 ? (1 - (totalDuration / 30)).clamp(0.0, 1.0) : 1.0;

  return SizedBox(
    width: 200,
    child: Column(
      children: [
        LinearPercentIndicator(
          percent: percentage,
          progressBorderColor: percentage < 0.5
              ? Colors.green
              : (percentage < 0.8 ? Colors.orange : Colors.red),
          progressColor: percentage < 0.5
              ? Colors.green
              : (percentage < 0.8 ? Colors.orange : Colors.red),
          lineHeight: 5.0,
          barRadius: const Radius.circular(5),
          alignment: MainAxisAlignment.start,
          animation: true,
          animationDuration: 500,
          animateToInitialPercent: true,
          animateFromLastPercent: true,
        ),
        if (percentage == 1)
          const Row(children: [
            Text(
              "Expired!",
              textAlign: TextAlign.left,
            )
          ]),
        if (percentage < 1)
          Row(
            children: [
              totalDuration == 1
                  ? Text('Expires in $totalDuration day')
                  : Text('Expires in $totalDuration days'),
            ],
          ),
      ],
    ),
  );
}
