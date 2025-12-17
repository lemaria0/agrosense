import 'sensor_model.dart';

// extenção para formatar horário
extension SensorModelExtensions on SensorModel {
  DateTime get dateTime {
    if (timestamp > 946684800000) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      final str = timestamp.toString().padLeft(12, '0');

      final day = int.parse(str.substring(0, 2));
      final month = int.parse(str.substring(2, 4));
      final year = int.parse(str.substring(4, 8));
      final hour = int.parse(str.substring(8, 10));
      final minute = int.parse(str.substring(10, 12));

      return DateTime(year, month, day, hour, minute);
    }
  }

  String get formattedTime {
    final dt = dateTime;

    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }
}
