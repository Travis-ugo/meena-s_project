import 'package:meena/feature/models/sensor.dart';
class Modality {
  final String modalityId;
  final String tenantId;
  final String name;
  final int type;
  final String sensorId;
  final Sensor sensor;
  final List<dynamic>? widgets;

  Modality({
    required this.modalityId,
    required this.tenantId,
    required this.name,
    required this.type,
    required this.sensorId,
    required this.sensor,
    required this.widgets,
  });

  factory Modality.fromJson(Map<String, dynamic> json) {
    return Modality(
      modalityId: json['modalityId'],
      tenantId: json['tenantId'],
      name: json['name'],
      type: json['type'],
      sensorId: json['sensorId'],
      sensor: Sensor.fromJson(json['sensor']),
      widgets: json['widgets'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modalityId': modalityId,
      'tenantId': tenantId,
      'name': name,
      'type': type,
      'sensorId': sensorId,
      'sensor': sensor.toJson(),
      'widgets': widgets,
    };
  }
}