import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sd/data/models/alert_model.dart';
import 'package:sd/data/models/alert_extentions.dart';
import 'package:sd/ui/pages/cards/alert_card.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({
    super.key,
    required this.alerts,
  });

  final List<AlertModel> alerts;

  @override
  Widget build(BuildContext context) {
    // agrupa os alertas por categoria
    final Map<String, List<AlertModel>> alertsByType = {};
    for (var alert in alerts) {
      alertsByType.putIfAbsent(alert.type.name, () => []).add(alert);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/alert-icon.svg",
                height: 20,
                colorFilter: ColorFilter.mode(
                  const Color(0xFFE74C3C),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Alertas",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 28),

          ...alertsByType.entries.map((entry) {
            final category = entry.key;
            String name = '';
            if (category == "ph") {
              name = "Acidez";
            }
            if (category == 'luminosity') {
              name = "Luminosidade";
            }
            if (category == "humidity") {
              name = "Umidade";
            }
            if (category == "temperature") {
              name = "Temperatura";
            }
            final reversed = entry.value.reversed.toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: reversed.map((alert) {
                      return AlertCard(
                        type: alert.type.name,
                        message: alert.msg,
                        time: alert.formattedTime,
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}