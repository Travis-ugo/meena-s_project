import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meena/feature/bloc/meena_bloc.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:meena/feature/presentation/chart.dart';
import 'package:meena/feature/services/api_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MeenaBloc(apiService)..add(const LoadDataDashboardEvent()),
      child: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  SfCartesianChart? _chart;

  @override
  void initState() {
    super.initState();
  }

  void _initializeTabController(int length) {
    _tabController = TabController(length: length, vsync: this);
    _tabController?.addListener(_handleTabSelection);
    int initialIndex = _tabController!.index;
    int dashboardId =
        context.read<MeenaBloc>().state.dashboards[initialIndex].dashboardId!;

    BlocProvider.of<MeenaBloc>(context)
        .add(LoadDashboardForTab(dashboardId: dashboardId));
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      int selectedIndex = _tabController!.index;
      int dashboardId = context
          .read<MeenaBloc>()
          .state
          .dashboards[selectedIndex]
          .dashboardId!;
      if (!context
          .read<MeenaBloc>()
          .state
          .dashboardData
          .containsKey(dashboardId)) {
        BlocProvider.of<MeenaBloc>(context)
            .add(LoadDashboardForTab(dashboardId: dashboardId));
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
    return BlocBuilder<MeenaBloc, MeenaState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (_tabController == null && state.dashboards.isNotEmpty) {
          _initializeTabController(state.dashboards.length);
        }

        return DefaultTabController(
          length: state.dashboards.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Meena's Project"),
              bottom: TabBar(
                controller: _tabController,
                tabs: state.dashboards.map((tab) {
                  return Tab(text: tab.name);
                }).toList(),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: state.dashboards.map(
                (tab) {
                  // print('${tab.dashboardId!} :::::::::::::::::::');
                  int dashboardId = tab.dashboardId!;

                  return Visibility(
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    visible: state.dashboardData.containsKey(dashboardId),
                    child: state.sensorDataMap[dashboardId] != null
                        ?

                        // Center(
                        //     child: Text('${state.sensorDataList.length}'),
                        //   )

                        ListView.builder(
                            itemCount: state.widgets.length,
                            itemBuilder: (context, index) {
                              // return

                              List<SensorData> sensorList = state
                                  .sensorDataMap[dashboardId]!.sensorDataList;
                              String sensorName =
                                  state.sensorDataMap[dashboardId]!.widgetName;
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
                                        isVisible: true,
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                // log('ERROR NOWNOWNOW');
                              }
                              return ChartPage(
                                chartType: sensorName,
                                sensordata: sensorList,
                              );
                            },
                          )
                        : const Center(
                            child: Text('Empty'),
                          ),
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }
}
