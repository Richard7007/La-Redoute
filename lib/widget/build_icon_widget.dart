import 'package:flutter/material.dart';

class BuildIconWidget extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const BuildIconWidget(
      {super.key, required this.icon, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}
