import 'package:sd/data/models/enum/data_type.dart';

// modelo do alerta
class AlertModel {
  final DataType type;
  final String msg;
  final int timestamp;

  const AlertModel({
    required this.type,
    required this.msg,
    required this.timestamp,
  });

  AlertModel copyWith({DataType? type, String? msg, int? timestamp}) {
    return AlertModel(
      type: type ?? this.type,
      msg: msg ?? this.msg,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      type: DataType.fromString(map['type'] ?? ''),
      msg: map['message'] ?? map['msg'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'timestamp': timestamp, 'msg': msg};
  }
}
