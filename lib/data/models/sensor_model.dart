import 'package:sd/data/models/enum/data_type.dart';

// modelo do sensor
class SensorModel {
  final String id;
  final DataType type;
  final double avg;
  final int timestamp;

  const SensorModel({
    required this.id,
    required this.type,
    required this.avg,
    required this.timestamp,
  });

  factory SensorModel.fromMap(Map<String, dynamic> map) {
    return SensorModel(
      id: map['id']?.toString() ?? '',
      type: DataType.fromString(map['type'] ?? ''),

      // Tenta ler 'avg' (Broker). Se for nulo, tenta 'value' (Java).
      // Se ambos forem nulos, usa 0.0.
      avg: (map['avg'] ?? map['value'] ?? 0.0).toDouble(),

      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type.name, 'avg': avg, 'timestamp': timestamp};
  }

  SensorModel copyWith({
    String? id,
    DataType? type,
    double? avg,
    int? timestamp,
  }) {
    return SensorModel(
      id: id ?? this.id,
      type: type ?? this.type,
      avg: avg ?? this.avg,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'SensorModel(id: $id, type: ${type.name}, avg: $avg, timestamp: $timestamp)';
  }
}
