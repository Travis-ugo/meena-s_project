import 'package:meena/feature/models/widget_model.dart';

class Dashboard {
  final int dashboardId;
  final String name;
  final int layoutId;
  final List<WidgetModel> widgets;
  final List<dynamic> devices; // Change type based on actual data

  Dashboard({
    required this.dashboardId,
    required this.name,
    required this.layoutId,
    required this.widgets,
    required this.devices,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      dashboardId: json['dashboardId'],
      name: json['name'],
      layoutId: json['layoutId'],
      widgets: (json['widgets'] as List)
          .map((e) => WidgetModel.fromJson(e))
          .toList(),
      devices: json['devices'], // Change type based on actual data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboardId': dashboardId,
      'name': name,
      'layoutId': layoutId,
      'widgets': widgets.map((e) => e.toJson()).toList(),
      'devices': devices,
    };
  }
}
