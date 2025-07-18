import 'package:ex_date/screens/profile_screen.dart';
import 'package:ex_date/widgets/calendar.dart';
import 'package:ex_date/widgets/charts/expiry_bar_chart.dart';
import 'package:ex_date/widgets/charts/expiry_line_chart.dart';
import 'package:ex_date/widgets/pie_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() {
    return _DashboardScreenState();
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<_DashboardItem> items = [
    _DashboardItem(
        "Expiry Pattern (in 7 days)", Icons.show_chart, buildLineChart()),
    _DashboardItem("Expiry by Date", Icons.bar_chart, buildChart()),
    _DashboardItem("Expiry status", Icons.pie_chart, buildPieChart()),
    _DashboardItem(
        "Calender View",
        Icons.calendar_month_outlined,
        CalendarView(
          expiryItemsByDate: getExpiryItemsByDate(),
        )),
    _DashboardItem("Profile", Icons.person, const ProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => item.destination));
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(item.title, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget destination;

  _DashboardItem(this.title, this.icon, this.destination);
}
