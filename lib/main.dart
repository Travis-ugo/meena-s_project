import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meena/feature/chart.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:meena/feature/models/dash_board_model.dart';
import 'package:meena/feature/models/widget_model.dart';
import 'package:meena/feature/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen());
  }
}

// class WidgetWithName {
//   const WidgetWithName(
//       {required this.sensorDataList, required this.widgetName});
//   final List<SensorData> sensorDataList;
//   final String widgetName;
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   final ApiService apiService = ApiService();
//   TabController? _tabController;
//   bool isLoading = true;
//   List<Dashboard> _dashboards = [];
//   // Map<int, WidgetModel> _widgetData = {};
//   Map<int, Dashboard> _dashboardData = {};
//   Map<int, WidgetWithName> sensorDataMap = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadDashboards();
//   }

//   Future<void> _loadDashboards() async {
//     List<Dashboard> dashboards = await apiService.fetchDashboards();

//     setState(() {
//       _dashboards = dashboards;
//       isLoading = false;
//       _tabController = TabController(length: _dashboards.length, vsync: this);
//       _tabController?.addListener(_handleTabSelection);
//     });

//     // Call _handleTabSelection manually for the initial tab
//     if (_tabController?.index != null) {
//       int initialIndex = _tabController!.index;
//       int dashboardId = _dashboards[initialIndex].dashboardId!;
//       _loadDashboardForTab(dashboardId);
//     }
//   }

//   void _handleTabSelection() {
//     if (_tabController!.indexIsChanging) {
//       int selectedIndex = _tabController!.index;
//       int dashboardId = _dashboards[selectedIndex].dashboardId!;
//       log('$dashboardId --------------');
//       _loadDashboardForTab(dashboardId);
//     }
//   }

//   Future<void> _loadDashboardForTab(int dashboardId) async {
//     Dashboard dashboard = await apiService.postDashBoardId(dashboardId);

//     log('${dashboard.name} ++++++++++');
//     setState(() {
//       _dashboardData[dashboardId] = dashboard;
//     });

//     log('$dashboardId ++++++++++ end');

//     for (var widget in dashboard.widgets!) {
//       WidgetModel widgets = await apiService.fetchWidget(
//         widgetId: "1",
//       ); //${widget.widgetId}");

//       setState(() {
//         if (widget.widgetId != null) {
//           _widgetData[widget.widgetId!] = widgets;
//         }
//       });
//       if (widgets.modalities != null) {
//         for (var modality in widgets.modalities!) {
//           log('HERE WIDGET NAME: ::::::: ${widgets.name}');
//           List<SensorData> sensorDataList = await apiService.fetchSensorData(
//               modalitiesId: modality.modalityId!);

//           setState(() {
//             sensorDataMap[dashboardId] = WidgetWithName(
//                 sensorDataList: sensorDataList,
//                 widgetName: widget.name != null ? widgets.name! : "EMPTY");
//           });
//           log('${sensorDataMap[dashboardId]!.sensorDataList.length}');
//           log('Widgetmodel Name: ${modality.name} ${modality.modalityId}');
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _tabController?.removeListener(_handleTabSelection);
//     _tabController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Container(
//             color: Colors.white,
//             child: const Center(
//               child: CircularProgressIndicator(),
//             ),
//           )
//         : DefaultTabController(
//             length: _dashboards.length,
//             child: Scaffold(
//               appBar: AppBar(
//                 title: const Text("Meena's Project"),
//                 bottom: TabBar(
//                   controller: _tabController,
//                   tabs: _dashboards.map((tab) {
//                     return Tab(text: tab.name);
//                   }).toList(),
//                 ),
//               ),
//               body: TabBarView(
//                 controller: _tabController,
//                 children: _dashboards.map((tab) {
//                   int dashboardId = tab.dashboardId!;
//                   // Ensure this widget builds with the latest sensor data
//                   return Visibility(
//                     replacement: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                     visible: _dashboardData.containsKey(dashboardId),
//                     child: sensorDataMap[dashboardId] != null
//                         ? ListView.builder(
//                             itemCount: sensorDataMap[dashboardId]
//                                     ?.sensorDataList
//                                     .length ??
//                                 0,
//                             itemBuilder: (context, index) {
//                               List<SensorData>? sensorList =
//                                   sensorDataMap[dashboardId]!.sensorDataList;
//                               String sensorName =
//                                   sensorDataMap[dashboardId]!.widgetName;
//                               return Container(
//                                 height: 300,
//                                 margin: const EdgeInsets.all(15),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: SfCartesianChart(
//                                   primaryXAxis: const CategoryAxis(),
//                                   title: ChartTitle(
//                                     text: sensorDataMap[index]!.widgetName,
//                                   ),
//                                   legend: const Legend(isVisible: true),
//                                   tooltipBehavior:
//                                       TooltipBehavior(enable: true),
//                                   series: <CartesianSeries<SensorData, String>>[
//                                     LineSeries<SensorData, String>(
//                                       dataSource: sensorList,
//                                       xValueMapper: (SensorData sensor, _) =>
//                                           sensor.d.isNotEmpty
//                                               ? sensor.d.first.toString()
//                                               : 'No Data',
//                                       yValueMapper: (SensorData sensor, _) =>
//                                           sensor.ts,
//                                       name: 'Data',
//                                       dataLabelSettings:
//                                           const DataLabelSettings(
//                                               isVisible: true),
//                                     )
//                                   ],
//                                 ),
//                               );
//                             },
//                           )
//                         : Center(
//                             child: Text('Empty'),
//                           ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           );
//   }
// }

class WidgetWithName {
  const WidgetWithName(
      {required this.sensorDataList, required this.widgetName});
  final List<SensorData> sensorDataList;
  final String widgetName;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  TabController? _tabController;
  bool isLoading = true;
  List<Dashboard> _dashboards = [];
  Map<int, Dashboard> _dashboardData = {};
  Map<int, WidgetWithName> sensorDataMap = {};
  SfCartesianChart? _chart; // Moved chart creation outside loop
  List<SensorData> sensorDataList = [];
  List<WidgetModel> widgets = [];

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  Future<void> _loadDashboards() async {
    List<Dashboard> dashboards = await apiService.fetchDashboards();

    setState(() {
      _dashboards = dashboards;
      isLoading = false;
      _tabController = TabController(length: _dashboards.length, vsync: this);
      _tabController?.addListener(_handleTabSelection);
    });

    // Call _handleTabSelection manually for the initial tab
    if (_tabController?.index != null) {
      int initialIndex = _tabController!.index;
      int dashboardId = _dashboards[initialIndex].dashboardId!;
      _loadDashboardForTab(dashboardId);
    }
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      int selectedIndex = _tabController!.index;
      int dashboardId = _dashboards[selectedIndex].dashboardId!;
      _loadDashboardForTab(dashboardId);
    }
  }

  Future<void> _loadDashboardForTab(int dashboardId) async {
    log("API CALLED");
    Dashboard dashboard = await apiService.postDashBoardId(dashboardId);

    setState(() {
      _dashboardData[dashboardId] = dashboard;
    });

    List<Future<WidgetModel>> widgetFutures = dashboard.widgets!.map((widget) {
      return apiService.fetchWidget(widgetId: "${widget.widgetId}")
          as Future<WidgetModel>;
    }).toList();

    widgets = await Future.wait(widgetFutures);

    for (int i = 0; i < widgets.length; i++) {
      WidgetModel widget = widgets[i];
      if (widget.modalities != null) {
        for (var modality in widget.modalities!) {
          var addSensorDataList = await apiService.fetchSensorData(
              modalitiesId: modality.modalityId!);
          sensorDataList.addAll(addSensorDataList);
          setState(() {
            sensorDataMap[dashboardId] = WidgetWithName(
                sensorDataList: sensorDataList,
                widgetName: widget.name ?? "EMPTY");
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : DefaultTabController(
            length: _dashboards.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Meena's Project"),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: _dashboards.map((tab) {
                    return Tab(text: tab.name);
                  }).toList(),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: _dashboards.map((tab) {
                  int dashboardId = tab.dashboardId!;
                  // Ensure this widget builds with the latest sensor data
                  return Visibility(
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    visible: _dashboardData.containsKey(dashboardId),
                    child: sensorDataMap[dashboardId] != null
                        ? ListView.builder(
                            itemCount:widgets.length,
                            //  sensorDataMap[dashboardId]!
                            //     .sensorDataList
                            //     .length,
                            itemBuilder: (context, index) {
                              List<SensorData> sensorList =
                                  sensorDataMap[dashboardId]!.sensorDataList;
                              String sensorName =
                                  sensorDataMap[dashboardId]!.widgetName;
                              if (_chart == null) {
                                _chart = SfCartesianChart(
                                  primaryXAxis: const CategoryAxis(),
                                  title: ChartTitle(text: sensorName),
                                  legend: const Legend(isVisible: true),
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <CartesianSeries<SensorData, String>>[
                                    LineSeries<SensorData, String>(
                                      dataSource: sensorList,
                                      xValueMapper: (SensorData sensor, _) =>
                                          sensor.d.isNotEmpty
                                              ? sensor.d.first.toString()
                                              : 'No Data',
                                      yValueMapper: (SensorData sensor, _) =>
                                          sensor.ts,
                                      name: 'Data',
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                              isVisible: true),
                                    )
                                  ],
                                );
                              } else {
                                // Update chart data source
                                // _chart!.series[0].dataSource = sensorList;

                                log('ERROR NOWNOWNOW');
                              }
                              return ChartPage(chartType: sensorName, sensordata: sensorList);
                              // Container(
                              //   height: 300,
                              //   margin: const EdgeInsets.all(15),
                              //   decoration: BoxDecoration(
                              //     border: Border.all(),
                              //     borderRadius: BorderRadius.circular(20),
                              //   ),
                              //   child: //_chart,
                              // );
                            },
                          )
                        : const Center(
                            child: Text('Empty'),
                          ),
                  );
                }).toList(),
              ),
            ),
          );
  }
}
