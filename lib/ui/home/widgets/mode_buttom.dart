import 'package:flutter/material.dart';
import 'package:sd/data/models/enum/comunication_mode.dart';

typedef ModeChangedCallback = void Function(CommunicationMode newMode);

class ModeButton extends StatelessWidget {
  const ModeButton({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final CommunicationMode mode;
  final ModeChangedCallback onModeChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CommunicationMode>(
      onSelected: onModeChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: CommunicationMode.mqtt,
          child: Text("MQTT"),
        ),
        PopupMenuItem(
          value: CommunicationMode.rmi,
          child: Text("RMI"),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: mode == CommunicationMode.mqtt
              ? const Color(0xFF4E82F0)
              : const Color(0xFF4EC835),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              mode == CommunicationMode.mqtt
                  ? Icons.wifi_tethering
                  : Icons.http,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              mode == CommunicationMode.mqtt ? "MQTT" : "RMI",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}