import 'package:flutter/material.dart';

class CalendarArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const CalendarArrow({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}
