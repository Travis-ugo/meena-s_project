import 'package:flutter/material.dart';
import 'package:meena/feature/models/dash_board_model.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:meena/feature/models/widget_model.dart';
import 'package:meena/feature/services/api_service.dart';

class MeenaProvider with ChangeNotifier {
  final ApiService apiService;

  MeenaProvider(this.apiService);

  bool _isLoading = false;
  List<Dashboard> _dashboards = [];
  Map<int, Dashboard> _dashboardData = {};
  Map<int, Map<String, Map<String, List<SensorData>>>> _dashboardSensorDataMap =
      {};

  bool get isLoading => _isLoading;
  List<Dashboard> get dashboards => _dashboards;
  Map<int, Dashboard> get dashboardData => _dashboardData;
  Map<int, Map<String, Map<String, List<SensorData>>>>
      get dashboardSensorDataMap => _dashboardSensorDataMap;

  Future<void> loadDataDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dashboards = await apiService.fetchDashboards();
    } catch (e) {
      _dashboards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardForTab(int dashboardId) async {
    try {
      Dashboard dashboard = await apiService.postDashBoardId(dashboardId);

      _dashboardData[dashboardId] = dashboard;

      List<Future<WidgetModel>> widgetFutures = dashboard.widgets!
          .map(
            (widget) => apiService.fetchWidget(widgetId: "${widget.widgetId}"),
          )
          .toList();

      final widgets = await Future.wait(widgetFutures);
      Map<String, Map<String, List<SensorData>>> widgetModalitySensorData = {};

      for (var widget in widgets) {
        Map<String, List<SensorData>> modalitySensorData = {};

        for (var modality in widget.modalities!) {
          List<SensorData> sensorDataList = await apiService.fetchSensorData(
            modalitiesId: modality.modalityId!,
          );
          modalitySensorData[modality.name!] = sensorDataList;
        }

        widgetModalitySensorData[widget.name!] = modalitySensorData;
      }

      _dashboardSensorDataMap = {
        ..._dashboardSensorDataMap,
        dashboardId: widgetModalitySensorData
      };

      notifyListeners();
    } catch (e) {
      // Handle errors if needed
    }
  }
}
