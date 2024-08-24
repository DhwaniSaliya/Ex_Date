import 'package:flutter/material.dart';

Color getColorIndicator(DateTime expiryDate) {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) {
      return Colors.red;
    } else if (expiryDate.isBefore(now.add(const Duration(days: 15)))) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
