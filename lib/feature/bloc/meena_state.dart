// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'meena_bloc.dart';

class MeenaState extends Equatable {
  const MeenaState({
    this.dashboards = const <Dashboard>[],
    this.isLoading = false,
    this.dashboardData = const {},
    this.dashboardSensorDataMap = const {},
  });

  final List<Dashboard> dashboards;
  final bool isLoading;
  final Map<int, Dashboard> dashboardData;
  final Map<int, Map<String, Map<String, List<SensorData>>>>
      dashboardSensorDataMap;

  @override
  List<Object> get props => [
        dashboards,
        isLoading,
        dashboardData,
        dashboardSensorDataMap,
      ];

  MeenaState copyWith({
    List<Dashboard>? dashboards,
    bool? isLoading,
    Map<int, Dashboard>? dashboardData,
    Map<int, Map<String, Map<String, List<SensorData>>>>?
        dashboardSensorDataMap,
  }) {
    return MeenaState(
      dashboards: dashboards ?? this.dashboards,
      isLoading: isLoading ?? this.isLoading,
      dashboardData: dashboardData ?? this.dashboardData,
      dashboardSensorDataMap:
          dashboardSensorDataMap ?? this.dashboardSensorDataMap,
    );
  }
}
