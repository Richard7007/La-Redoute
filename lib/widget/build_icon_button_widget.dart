import 'package:flutter/material.dart';

class BuildIconButtonWidget extends StatelessWidget {
  final Icon? icon;
  final double? size;
  final void Function()? onPressed;
  final Color? color;

  const BuildIconButtonWidget(
      {super.key, this.icon, this.onPressed, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon ??
          Icon(
            Icons.error,
            color: color,
            size: size,
          ),
    );
  }
}
