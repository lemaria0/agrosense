import 'package:flutter/material.dart';

class AcidityCard extends StatelessWidget {
  final double value;
  final String time;

  const AcidityCard({super.key, required this.value, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 170,
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
        children: [
          const Text("Escala PH", style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(time, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}