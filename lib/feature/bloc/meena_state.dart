// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'meena_bloc.dart';

class MeenaState extends Equatable {
  const MeenaState({
    this.dashboards = const <Dashboard>[],
    this.isLoading = false,
    this.dashboardData = const {},
    this.sensorDataMap = const {},
    this.sensorDataList = const [],
    this.widgets = const [],
  });

  final List<Dashboard> dashboards;
  final bool isLoading;
  final Map<int, Dashboard> dashboardData;
  final Map<int, WidgetWithName> sensorDataMap;
  final List<SensorData> sensorDataList;
  final List<WidgetModel> widgets;

  @override
  List<Object> get props => [
        dashboards,
        isLoading,
        dashboardData,
        sensorDataMap,
        sensorDataList,
        widgets,
      ];

  MeenaState copyWith({
    List<Dashboard>? dashboards,
    bool? isLoading,
    Map<int, Dashboard>? dashboardData,
    Map<int, WidgetWithName>? sensorDataMap,
    List<SensorData>? sensorDataList,
    List<WidgetModel>? widgets,
  }) {
    return MeenaState(
      dashboards: dashboards ?? this.dashboards,
      isLoading: isLoading ?? this.isLoading,
      dashboardData: dashboardData ?? this.dashboardData,
      sensorDataMap: sensorDataMap ?? this.sensorDataMap,
      sensorDataList: sensorDataList ?? this.sensorDataList,
      widgets: widgets ?? this.widgets,
    );
  }
}
