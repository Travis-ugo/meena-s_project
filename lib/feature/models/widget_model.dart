import 'package:meena/feature/models/modality.dart';

class WidgetModel {
  final int widgetId;
  final String name;
  final int type;
  final String graphParameters;
  final int dashboardId;
  final List<Modality> modalities;

  WidgetModel({
    required this.widgetId,
    required this.name,
    required this.type,
    required this.graphParameters,
    required this.dashboardId,
    required this.modalities,
  });

  factory WidgetModel.fromJson(Map<String, dynamic> json) {
    return WidgetModel(
      widgetId: json['widgetId'],
      name: json['name'],
      type: json['type'],
      graphParameters: json['graphParameters'],
      dashboardId: json['dashboardId'],
      modalities: (json['modalities'] as List)
          .map((i) => Modality.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'widgetId': widgetId,
      'name': name,
      'type': type,
      'graphParameters': graphParameters,
      'dashboardId': dashboardId,
      'modalities': modalities.map((e) => e.toJson()).toList(),
    };
  }
}



