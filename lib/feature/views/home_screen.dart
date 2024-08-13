import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:meena/feature/views/chart.dart';
import 'package:meena/feature/services/api_service.dart';
import 'package:meena/feature/view_models/provider_api_service.dart';
import 'package:provider/provider.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeenaProvider(apiService)..loadDataDashboard(),
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

  @override
  void initState() {
    super.initState();
  }

  void _initializeTabController(int length) {
    _tabController = TabController(length: length, vsync: this);
    _tabController?.addListener(_handleTabSelection);
    int initialIndex = _tabController!.index;
    int dashboardId =
        context.read<MeenaProvider>().dashboards[initialIndex].dashboardId!;

    context.read<MeenaProvider>().loadDashboardForTab(dashboardId);
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      int selectedIndex = _tabController!.index;
      int dashboardId =
          context.read<MeenaProvider>().dashboards[selectedIndex].dashboardId!;
      if (!context
          .read<MeenaProvider>()
          .dashboardData
          .containsKey(dashboardId)) {
        context.read<MeenaProvider>().loadDashboardForTab(dashboardId);
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
    return Consumer<MeenaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (_tabController == null && provider.dashboards.isNotEmpty) {
          _initializeTabController(provider.dashboards.length);
        }

        return DefaultTabController(
          length: provider.dashboards.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Meena's Project"),
              bottom: TabBar(
                controller: _tabController,
                tabs: provider.dashboards.map((tab) {
                  return Tab(text: tab.name);
                }).toList(),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: provider.dashboards.map(
                (tab) {
                  int dashboardId = tab.dashboardId!;

                  log('${provider.dashboardSensorDataMap}');
                  return Visibility(
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    visible: provider.dashboardData.containsKey(dashboardId),
                    child: provider.dashboardSensorDataMap[dashboardId]
                                ?.isNotEmpty ??
                            false
                        ? ListView.builder(
                            itemCount: provider
                                .dashboardSensorDataMap[dashboardId]?.length,
                            itemBuilder: (context, index) {
                              String chartType = provider
                                  .dashboardSensorDataMap[dashboardId]!.keys
                                  .elementAt(index);
                              Map<String, List<SensorData>> modalityData =
                                  provider.dashboardSensorDataMap[dashboardId]![
                                      chartType]!;

                              return ChartPage(
                                chartType: chartType,
                                modalityData: modalityData,
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "NO DATA",
                              style: TextStyle(fontSize: 24),
                            ),
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
