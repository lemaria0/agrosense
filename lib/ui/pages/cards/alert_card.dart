import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String message;
  final String type;
  final String time;

  const AlertCard({super.key, required this.message, required this.type, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // importante
        children: [
          Text(type),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(time),
        ],
      ),
    );
  }
}