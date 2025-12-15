import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sd/data/models/sensor_model.dart';
import 'package:sd/data/models/sensor_extentions.dart';
import 'package:sd/ui/pages/cards/luminosity_card.dart';

class LuminosityPage extends StatelessWidget {
  const LuminosityPage({
    super.key,
    required this.devices,
  });

  final Map<String, List<SensorModel>> devices;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/sun-icon.svg",
                height: 25,
                colorFilter: ColorFilter.mode(
                  Color(0xFF4E82F0),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Luminosidade",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 28),

          Expanded(
            child: ListView(
              children: devices.entries.map((entry) {
                final deviceName = entry.key;
                final readings = entry.value;
                final reversed = readings.reversed.toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Text(
                            deviceName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: reversed.map((sensor) {
                          return LuminosityCard(
                            value: sensor.avg,
                            time: sensor.formattedTime,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}