// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import 'package:meena/feature/view_models/api_service.dart';

// import '../models/dash_board_model.dart';
// import '../models/sensor.dart';

// class DashboardProvider with ChangeNotifier {
//   final String token;
//   final ApiService apiService;
  
//   final FlutterSecureStorage secureStorage;


//   DashboardProvider({
//     required this.token,
//     required this.apiService,
//     required this.secureStorage,
//   });
//   static const dashboardsUrl = 'Dashboard';
//   static const dashboarddetailsUrl = 'Dashboard/Details/';
//   static const modalityUrl = "SensorDatas/";
//   bool _isLoading = false;
//   List<DashboardModel> _dashboards = [];
//   Map<int, DashboardModel> _dashboardData = {};
//   Map<int, Map<int, Map<String, List<SensorData>>>> _dashboardSensorDataMap =
//       {};
//   Map<int, Map<int, String>> _chartSensorDataMap = {};

//   bool get isLoading => _isLoading;
//   List<DashboardModel> get dashboards => _dashboards;
//   Map<int, DashboardModel> get dashboardData => _dashboardData;
//   Map<int, Map<int, Map<String, List<SensorData>>>>
//       get dashboardSensorDataMap => _dashboardSensorDataMap;
//   Map<int, Map<int, String>> get chartSesnsorDataMap => _chartSensorDataMap;

//   Future<void> loadDataDashboard() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       var accessToken = await retrieveToken();
//       final responseData =
//           await apiService.getwithToken(dashboardsUrl, accessToken, false);
//       var data = responseData as List;
//       _dashboards = data.map((json) => DashboardModel.fromJson(json)).toList();
//     } catch (e) {
//       _dashboards = [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<String> retrieveToken() async {
//     String? token = await secureStorage.read(key: 'user_token');
//     if (token != null) {
//       return token;
//     } else {
//       return "";
//     }
//   }

//   Future<void> loadDashboardForTab(int dashboardId) async {
//     try {
//       var accessToken = await retrieveToken();
//       var data = await apiService.postMultipartwithToken(dashboarddetailsUrl,
//           accessToken, {'dashboardId': dashboardId.toString()});
//       DashboardModel dashboard = DashboardModel.fromJson(data);
//       _dashboardData[dashboardId] = dashboard;

//       final widgets = dashboard.widgets ?? [];
//       Map<int, Map<String, List<SensorData>>> widgetModalitySensorData = {};
//       Map<int, String> widgetchartType = {};
//       for (var widget in widgets) {
//         Map<String, dynamic> graphParameters =
//             jsonDecode(widget.graphParameters!);
//         var configData = graphParameters['configdata'];
//         List<dynamic> yAxisData = configData['yAxis'];
//         int timeRangeMinutes = int.parse(configData['timeRange']);
//         DateTime endTime = DateTime.now();
//         DateTime startTime =
//             endTime.subtract(Duration(minutes: timeRangeMinutes));

//         // Convert to Unix timestamps
//         int endTimeUnix = endTime.millisecondsSinceEpoch ~/ 1000;
//         int startTimeUnix = startTime.millisecondsSinceEpoch ~/ 1000;
//         Map<String, List<SensorData>> modalitySensorData = {};
//         for (var yAxis in yAxisData) {
//           for (var modality in widget.modalities!) {
//             if (yAxis == modality.name) {
//               List<dynamic> jsonData = await apiService.getwithTimestamp(
//                   modalityUrl,
//                   modality.modalityId!,
//                   startTimeUnix.toString(),
//                   endTimeUnix.toString(),
//                   accessToken);
//               List<SensorData> sensorDataList =
//                   jsonData.map((json) => SensorData.fromJson(json)).toList();
//               modalitySensorData[modality.name!] = sensorDataList;
//             }
//           }
//           widgetchartType[widget.widgetId!] = widget.name!;
//           widgetModalitySensorData[widget.widgetId!] = modalitySensorData;
//         }
//       }

//       _chartSensorDataMap = {
//         ...chartSesnsorDataMap,
//         dashboardId: widgetchartType
//       };
//       _dashboardSensorDataMap = {
//         ..._dashboardSensorDataMap,
//         dashboardId: widgetModalitySensorData
//       };
//       notifyListeners();
//     } catch (e) {
//       // Handle errors if needed
//     }
//   }

//   void navigateToLogin(BuildContext context) {
//     Navigator.of(context).pushReplacementNamed('/login');
//   }

//   void navigateToHome(BuildContext context) {
//     Navigator.of(context).pushReplacementNamed('/home');
//   }
// }






// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:meena/feature/view_models/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dash_board_model.dart';
import '../models/sensor.dart';

class DashboardProvider with ChangeNotifier {
  final String token;
  final ApiService apiService;
  SharedPreferences? _sharedPreferences;

  DashboardProvider({
    required this.token,
    required this.apiService,
    SharedPreferences? sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;
  static const dashboardsUrl = 'Dashboard';
  static const dashboarddetailsUrl = 'Dashboard/Details/';
  static const modalityUrl = "SensorDatas/";
  bool _isLoading = false;
  List<DashboardModel> _dashboards = [];
  Map<int, DashboardModel> _dashboardData = {};
  Map<int, Map<int, Map<String, List<SensorData>>>> _dashboardSensorDataMap =
      {};
  Map<int, Map<int, String>> _chartSensorDataMap = {};

  bool get isLoading => _isLoading;
  List<DashboardModel> get dashboards => _dashboards;
  Map<int, DashboardModel> get dashboardData => _dashboardData;
  Map<int, Map<int, Map<String, List<SensorData>>>>
      get dashboardSensorDataMap => _dashboardSensorDataMap;
  Map<int, Map<int, String>> get chartSesnsorDataMap => _chartSensorDataMap;

  Future<void> loadDataDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      var accessToken = await retrieveToken();
      final responseData =
          await apiService.getwithToken(dashboardsUrl, accessToken, false);
      var data = responseData as List;
      _dashboards = data.map((json) => DashboardModel.fromJson(json)).toList();
    } catch (e) {
      _dashboards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> retrieveToken() async {
      _sharedPreferences ??= await SharedPreferences.getInstance();
    String? token = _sharedPreferences?.getString('user_token');
    if (token != null) {
      return token;
    } else {
      return "";
    }
  }

  Future<void> loadDashboardForTab(int dashboardId) async {
  try {
    _isLoading = true;
    notifyListeners();

    String accessToken = await retrieveToken();
    var data = await apiService.postMultipartwithToken(dashboarddetailsUrl, accessToken, {'dashboardId': dashboardId.toString()});
    DashboardModel dashboard = DashboardModel.fromJson(data);
    _dashboardData[dashboardId] = dashboard;

    await _loadWidgetData(dashboard, accessToken);

    notifyListeners();
  } catch (e) {
    // Handle errors if needed
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
Future<void> _loadWidgetData(DashboardModel dashboard, String accessToken) async {
  final widgets = dashboard.widgets ?? [];
  Map<int, Map<String, List<SensorData>>> widgetModalitySensorData = {};
  Map<int, String> widgetChartType = {};

  for (var widget in widgets) {
    Map<String, dynamic> graphParameters = jsonDecode(widget.graphParameters!);
    var configData = graphParameters['configdata'];
    List<dynamic> yAxisData = configData['yAxis'];
    int timeRangeMinutes = int.parse(configData['timeRange']);
    DateTime endTime = DateTime.now();
    DateTime startTime = endTime.subtract(Duration(minutes: timeRangeMinutes));

    int endTimeUnix = endTime.millisecondsSinceEpoch ~/ 1000;
    int startTimeUnix = startTime.millisecondsSinceEpoch ~/ 1000;
    Map<String, List<SensorData>> modalitySensorData = {};

    for (var yAxis in yAxisData) {
      for (var modality in widget.modalities!) {
        if (yAxis == modality.name) {
          List<dynamic> jsonData = await apiService.getwithTimestamp(modalityUrl, modality.modalityId!, startTimeUnix.toString(), endTimeUnix.toString(), accessToken);
          List<SensorData> sensorDataList = jsonData.map((json) => SensorData.fromJson(json)).toList();
          modalitySensorData[modality.name!] = sensorDataList;
        }
      }
      widgetChartType[widget.widgetId!] = widget.name!;
      widgetModalitySensorData[widget.widgetId!] = modalitySensorData;
    }
  }

  _chartSensorDataMap = {..._chartSensorDataMap, dashboard.dashboardId!: widgetChartType};
  _dashboardSensorDataMap = {..._dashboardSensorDataMap, dashboard.dashboardId!: widgetModalitySensorData};
}


  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
