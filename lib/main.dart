import 'dart:developer';

import 'package:flutter/material.dart';
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
  Map<int, WidgetModel> _widgetData = {};
  Map<int, Dashboard> _dashboardData = {};
  Map<int, List<SensorData>> sensorDataMap = {};

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
      int dashboardId = _dashboards[initialIndex].dashboardId;
      _loadDashboardForTab(dashboardId);
    }
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      int selectedIndex = _tabController!.index;
      int dashboardId = _dashboards[selectedIndex].dashboardId;
      log('$dashboardId --------------');
      _loadDashboardForTab(dashboardId);
    }
  }

  Future<void> _loadDashboardForTab(int dashboardId) async {
    Dashboard dashboard = await apiService.postDashBoardId(dashboardId);

    log('${dashboard.name} ++++++++++');
    setState(() {
      _dashboardData[dashboardId] = dashboard;
    });

    log('$dashboardId ++++++++++ end');

    for (var widget in dashboard.widgets) {
      WidgetModel widgets = await apiService.fetchWidget(
        widgetId: "2",
      ); //${widget.widgetId}");

      setState(() {
        _widgetData[widget.widgetId] = widgets;
      });

      for (var modality in widgets.modalities) {
        log('HERE');
        List<SensorData> sensorDataList =
            await apiService.fetchSensorData(modalitiesId: modality.modalityId);

        setState(() {
          sensorDataMap[dashboardId] = sensorDataList;
        });
        log('${sensorDataMap[dashboardId]}');
        log('Widgetmodel Name: ${modality.name} ${modality.modalityId}');
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
                  int dashboardId = tab.dashboardId;

                  // Ensure this widget builds with the latest sensor data
                  return Visibility(
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    visible: _dashboardData.containsKey(dashboardId),
                    child: ListView.builder(
                      itemCount: sensorDataMap[dashboardId]?.length ?? 0,
                      itemBuilder: (context, index) {
                        List<SensorData>? sensorList =
                            sensorDataMap[dashboardId];
                        return Container(
                          height: 300,
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(),
                            title: const ChartTitle(
                              text: 'Sensor Data Analysis',
                            ),
                            legend: const Legend(isVisible: true),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<SensorData, String>>[
                              LineSeries<SensorData, String>(
                                dataSource: sensorList!,
                                xValueMapper: (SensorData sensor, _) =>
                                    sensor.d.isNotEmpty
                                        ? sensor.d.first.toString()
                                        : 'No Data',
                                yValueMapper: (SensorData sensor, _) =>
                                    sensor.ts,
                                name: 'Data',
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          );
  }
}
