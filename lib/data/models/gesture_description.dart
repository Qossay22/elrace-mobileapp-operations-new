import 'package:flutter/material.dart';

class GestureDescription {
  final IconData icon;
  final String title;
  final String step;
  final String? statusKey;

  GestureDescription({
    required this.icon,
    required this.title,
    required this.step,
    this.statusKey,
  });
}
