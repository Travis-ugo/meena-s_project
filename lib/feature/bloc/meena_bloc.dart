import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meena/feature/models/dash_board_model.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:meena/feature/models/widget_model.dart';
import 'package:meena/feature/services/api_service.dart';

part 'meena_event.dart';
part 'meena_state.dart';

class MeenaBloc extends Bloc<MeenaEvent, MeenaState> {
  final ApiService apiService;

  MeenaBloc(this.apiService) : super(const MeenaState()) {
    on<LoadDataDashboardEvent>(onLoadDataDashboardEvent);
    on<LoadDashboardForTab>(onLoadDashboardForTab);
  }
  Map<int, Dashboard> dashboardData = {};
  List<Dashboard> dashboards = [];

  Future<void> onLoadDataDashboardEvent(
    LoadDataDashboardEvent event,
    Emitter<MeenaState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      dashboards = await apiService.fetchDashboards();
      emit(state.copyWith(
        dashboards: dashboards,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> onLoadDashboardForTab(
      LoadDashboardForTab event, Emitter<MeenaState> emit) async {
    Dashboard dashboard = await apiService.postDashBoardId(event.dashboardId!);
    dashboardData[event.dashboardId!] = dashboard;

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

    var updatedSensorDataMap = {
      ...state.dashboardSensorDataMap,
      event.dashboardId!: widgetModalitySensorData
    };

    emit(state.copyWith(
      dashboardData: dashboardData,
      dashboardSensorDataMap: updatedSensorDataMap,
    ));
  }
}
