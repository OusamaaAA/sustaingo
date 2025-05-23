import 'package:flutter/material.dart';

class RefreshableWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? indicatorColor;
  final Color? backgroundColor;
  final double displacement;

  const RefreshableWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.indicatorColor,
    this.backgroundColor,
    this.displacement = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: indicatorColor ?? Theme.of(context).primaryColor,
      backgroundColor: backgroundColor ?? Colors.white,
      displacement: displacement,
      edgeOffset: 0,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}