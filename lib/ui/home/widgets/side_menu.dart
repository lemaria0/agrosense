import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final int unseenAlertsCount;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.unseenAlertsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle("SENSORES"),
          _item("Temperatura", 0),
          _item("Umidade", 1),
          _item("Acidez", 2),
          _item("Luminosidade", 3),

          const SizedBox(height: 30),
          _buildSectionTitle("NOTIFICAÇÕES"),
          _item("Notificações", 4, unseenCount: unseenAlertsCount), // recebe a quantidade de alertas não lidos
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _item(String text, int index, {int unseenCount = 0}) {
    return InkWell(
      onTap: () => onSelect(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        color: index == selectedIndex ? Colors.white : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: index == selectedIndex ? Colors.black : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unseenCount > 0)
              Container(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFE74C3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unseenCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}