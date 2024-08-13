import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meena/feature/bloc/meena_bloc.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:meena/feature/presentation/chart.dart';
import 'package:meena/feature/services/api_service.dart';

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
                  int dashboardId = tab.dashboardId!;
                  Map<String, Map<String, List<SensorData>>>? sensorDataMap =
                      state.dashboardSensorDataMap[dashboardId];

                  return Visibility(
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    visible: state.dashboardData.containsKey(dashboardId),
                    child: sensorDataMap != null
                        ? ListView.builder(
                            itemCount: sensorDataMap.length,
                            itemBuilder: (context, index) {
                              String chartType =
                                  sensorDataMap.keys.elementAt(index);
                              Map<String, List<SensorData>> modalityData =
                                  sensorDataMap[chartType]!;

                              return ChartPage(
                                chartType: chartType,
                                modalityData: modalityData,
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'EMPTY DATA',
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
