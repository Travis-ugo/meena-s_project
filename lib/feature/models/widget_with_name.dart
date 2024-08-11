import 'package:meena/feature/models/sensor.dart';

class WidgetWithName {
  const WidgetWithName(
      {required this.sensorDataList, required this.widgetName});
  final List<SensorData> sensorDataList;
  final String widgetName;
}
