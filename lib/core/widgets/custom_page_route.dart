import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AxisDirection direction;

  CustomPageRoute({
    required this.child,
    this.direction = AxisDirection.right,
  }) : super(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = Curves.easeInOut;

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
              reverseCurve: Curves.easeInOut,
            );

            final offsetAnimation = Tween<Offset>(
              begin: _getBeginOffset(direction),
              end: Offset.zero,
            ).animate(curvedAnimation);

            return SlideTransition(
              position: offsetAnimation,
              child: child, // ← no FadeTransition here
            );
          },
        );

  static Offset _getBeginOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }
}
